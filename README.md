# TemplateApp
Template for application install with AppCICD

When working with a pipeline, the fist step is to install the infrastructure. After that, the App needs to be installed. In an internal IT organisation, many applications need to be installed, and this needs to be done with as little as possible hassle for the application teams.
As a result, it is wise to put the mechanics in a git submodule, leaving only the application specific data in the repo for the application itself. 

When cloning, as explained in [git submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules), two commands must be executed: 

```git submodule init```

to initialize your local configuration file, and 

```git submodule update``` 

to fetch all the data from that project and check out the appropriate commit listed in your application project.
