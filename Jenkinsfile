// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.

import groovy.json.JsonSlurper

this_stage = "None"
gitCommit = ""
cml_token = "12345"
thisSecret = "verysecret"
agentName = ""
this_branch = ""
this_build = ""

pipeline {
    agent none

    parameters {
        string(name: 'environment', defaultValue: 'default', description: 'Workspace/environment file to use for deployment')
        string(name: 'version', defaultValue: '', description: 'Version variable to pass to Terraform')
        booleanParam(name: 'autoApprove', defaultValue: false, description: 'Automatically run apply after generating plan?')
    }

    environment {
        JENKINS_CRED = credentials('jenkins-jenkins')
        NEXUS_CRED = credentials('jenkins-nexus')
        GIT_REPO_NAME = "AppCICD" 
    }

    stages {
        stage('Develop') {
            agent { 
                node { 
                    label 'Dev' 
                } 
            }
            stages {
                stage ('Collect data') {
                    steps {
                        collect_vars("Dev", "Dev")
                    }
                }
                stage ('Switch to build node') {
                    steps {
                        prepare("${this_stage}", "${gitCommit}")
                    }
                }
                stage ('Deploy infra') {
                    stages {
                        stage('Plan') {
                            steps {
                                script {
                                    currentBuild.displayName = params.version
                                }
                                sh 'terraform -chdir=myAppCICD init -input=false'
                                sh 'terraform -chdir=myAppCICD plan -input=false'
                            }
                        }
                         stage('Apply') {
                             steps {
                                 sh "terraform -chdir=myAppCICD apply -input=false -auto-approve -var-file='../testapp.auto.tfvars.json'"
                             }
                         }
                    }
                }
                stage ('Installing Presentation layer servers') {
                    steps {
                        echo "Start Application Installation ${this_stage} Presentation layer"
                        startplaybook("${this_stage}","Presentation")
                    }
                }
                stage ('Installing Application layer servers') {
                    steps {
                        echo "Start Application Installation ${this_stage} Application layer"
                        startplaybook("${this_stage}","Application")
                    }
                }
                stage ('Installing Data layer servers') {
                    steps {
                        echo "Start Application Installation ${this_stage} Data layer"
                        startplaybook("${this_stage}","Data")
                    }
                }
                stage('Smoke test') {
                    steps {
                        script {
                            sh "robot --variable VALID_PASSWORD:${thisSecret} -d  test_results --variable NODE:PS1 --variable STAGE:Dev robot/smoketest.robot"
                            currentBuild.result = 'SUCCESS'
                        }
                    }
                }
                stage ('Cleaning...') {
                    steps {
                        cleanup("Develop", "${gitCommit}", "${cml_token}")
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                step(
                [
                    $class              : 'RobotPublisher',
                    outputPath          : 'test_results',
                    outputFileName      : 'output.xml',
                    reportFileName      : 'report.html',
                    logFileName         : 'log.html',
                    disableArchiveOutput: true,
                    otherFiles          : "*.png,*.jpg",
                ]
                )
            }
            echo "Archiving artifacts"
            //archiveArtifacts artifacts: '**/*', fingerprint: true
            //junit 'build/reports/**/*.xml'
        }
        success {
            echo "Build ${env.BUILD_tag}, commit: ${gitCommit} was a success."
            //mail to: 'architect@infraautomator.example.com',
            //subject: "Build ${env.BUILD_tag}, commit: ${gitCommit} was successful.",
            //body: "Build is on branch ${env.JOB_NAME}"
        }
        unsuccessful {
            echo "Build ${env.BUILD_tag}, commit: ${gitCommit} failed."
            //mail to: 'architect@infraautomator.example.com',
            //subject: "Build ${env.BUILD_tag}, commit: ${gitCommit} was successful.",
            //body: "Build is on branch ${env.JOB_NAME}"
        }
        changed {
            echo "${env.JOB_NAME} behaved differently last time..."
        }
    }
}

def collect_vars(stage, my_env) {
    script {
        // Set global variables
        gitCommit = "${env.GIT_COMMIT[0..7]}"
        this_stage= "${stage}"
        this_branch="${env.BRANCH_NAME}"
        this_build="${env.BUILD_tag}"
    }                       
    echo "The commit is on branch ${env.JOB_NAME}, with short ID: ${gitCommit}"
    echo 'Creating Jenkins Agent'
    script {
        thisSecret = startagent("${env.BRANCH_NAME}","${env.BUILD_tag}","${gitCommit}")
    }

    script {
        agentName = "${GIT_REPO_NAME}-${env.BRANCH_NAME}-${gitCommit}"
    }
    echo "The agent for the next phase is: ${agentName}"

    return null
}

def prepare(stage, commit) {
    echo "Switched to jenkins agent: ${GIT_REPO_NAME}-${env.BRANCH_NAME}-${stage}-${commit}"
    checkout([
        $class: 'GitSCM',
        branches: scm.branches,
        doGenerateSubmoduleConfigurations: true,
        extensions: scm.extensions + [[$class: 'SubmoduleOption', parentCredentials: true]],
        userRemoteConfigs: scm.userRemoteConfigs
    ])
    return null
}

def startagent(branch, build, commit) {
    echo "Create Jenkins build node placeholder for repository: ${GIT_REPO_NAME}, branch: ${branch}, build: ${build} (commit:  ${commit})"
    sh 'curl -L -s -o /dev/null -u ' + "${JENKINS_CRED}" + ' -H Content-Type:application/x-www-form-urlencoded -X POST -d \'json={"name":+"' + "${GIT_REPO_NAME}" + "-" + "${branch}" + "-" + "${commit}" + '",+"nodeDescription":+"AppCICD+host:+' + "${GIT_REPO_NAME}" + "-" + "${branch}" + "-" + "${commit}" + '",+"numExecutors":+"1",+"remoteFS":+"/home/jenkins",+"labelString":+"' + "${GIT_REPO_NAME}" + "-" + "${branch}" + "-"+ "${commit}" + '",+"mode":+"EXCLUSIVE",+"":+["hudson.slaves.JNLPLauncher",+"hudson.slaves.RetentionStrategy$Always"],+"launcher":+{"stapler-class":+"hudson.slaves.JNLPLauncher",+"$class":+"hudson.slaves.JNLPLauncher",+"workDirSettings":+{"disabled":+false,+"workDirPath":+"",+"internalDir":+"remoting",+"failIfWorkDirIsMissing":+false},+"tunnel":+"",+"vmargs":+""},+"retentionStrategy":+{"stapler-class":+"hudson.slaves.RetentionStrategy$Always",+"$class":+"hudson.slaves.RetentionStrategy$Always"},+"nodeProperties":+{"stapler-class-bag":+"true"},+"type":+"hudson.slaves.DumbSlave"}\' "' + "${env.JENKINS_URL}" + 'computer/doCreateItem?name="' + "${GIT_REPO_NAME}" + "-" + "${branch}" + "-" + "${commit}" + '"&type=hudson.slaves.DumbSlave"'

    echo 'Retrieve Agent Secret'
    script {
        agentSecret = jenkins.model.Jenkins.getInstance().getComputer("${GIT_REPO_NAME}" + "-" + "${branch}" + "-" + "$commit").getJnlpMac()
    }

    return "${agentSecret}"
}

def stopagent(branch, build, commit) {
    echo "Remove Jenkins build node placeholder for repository: ${GIT_REPO_NAME}, branch: ${branch}, build: ${build} (commit:  ${commit})"
    sh 'curl -L -s -o /dev/null -u ' + "${JENKINS_CRED}" + ' -H "Content-Type:application/x-www-form-urlencoded" -X POST "' + "${env.JENKINS_URL}" + 'computer/' + "${GIT_REPO_NAME}" + "-" + "${branch}" + "-" + "${commit}" + '/doDelete"'
    
    return null
}

def startplaybook(stage,compartiment) {
    ansiblePlaybook installation: 'ansible', inventory: "./AppCICD/terraform.py", playbook: "${stage}.yml", extraVars: ["omgeving": "${stage}", "compartiment": "${compartiment}"], extras: '-vvvv'

}

def cleanup(env, commit, token) {
    echo "Switch to jenkins agent: ${env}"

    echo 'Remove Jenkins Agent'
    stopagent("${this_branch}","${this_build}","${commit}")
    /* clean up our workspace */
    deleteDir() 
    return null
}