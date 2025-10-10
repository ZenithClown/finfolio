<div align = "center">

# Contributing to `neuralNOD`
[![neuralNOD INC](https://img.shields.io/badge/🧠-neuralNOD_INC-blue)](https://github.com/neuralNOD)
[![REPO:ADMIN](https://img.shields.io/badge/👔-nxLogics-2A8542)](https://github.com/nxlogics)

</div>

<div align = "justify">

First and foremost, 🙏 thank you for considering to contribute to `neuralNOD`. We are currently
working on the following [projects/products](#void). The projects are mostly optimized and
custom built for internal usages. New members, or external contributors are requested to adhere to
the [Code of Conduct](CODE_OF_CONDUCT.md), and are requested to first discuss the changes via
an issue, or as directed by project owners.

The commit messages are open-ended and not much restricted, however
[best practices](https://gist.github.com/robertpainsi/b632364184e70900af4ab688decf6f53) are
mentioned for your reference. To get an overview of the project, read the [README](../README.md).

## Getting Started

A set of ⚙ configuration repositories were being actively developed to manage the overall product. The
repositories are custom built to serve functionalities (check the individual repository read me files
for more information). To start as a developer, it is recommended to create an environment and install the
configuration/meta repositories with `git` like:

```shell
virtualenv neuralnod # https://virtualenv.pypa.io/en/latest/user_guide.html

# settings maintained by: https://gist.github.com/nxlogics
# the codes are generally to be run directly from the source, else added as submodule
git clone https://gist.github.com/nxlogics/157cfcf13756b56d8e37081590a5d425.git METADATA_DATASOURCE
```

A _`skeleton`_ repository is developed [**`ndprdconfig`**](https://github.com/neuralNOD/ndprdconfig) that
can be utilized for quickly setting up configurations (like database configuration settings). This is
an optional repository, but can be utilized to manage multiple instances.

```shell
git clone https://github.com/neuralNOD/ndprdconfig.git # setup config files
```

To learn about `PYTHONPATH` check
[this link](https://medium.com/chingu/an-introduction-to-environment-variables-and-how-to-use-them-f602f66d15fa).
The repositories which are configured with `setup.py` or `pyproject.toml` can
be installed in editable mode in the created virtual environment like:

```shell
/path/to/repository$ pip install -e .
```

### Issues

If you spot a problem with any of the funtionalities/documentations then first [search if an issue already exists](https://docs.github.com/en/github/searching-for-information-on-github/searching-on-github/searching-issues-and-pull-requests#search-by-the-title-body-or-comments). If a
related issue doesn't exist, you can open a new issue using a relevant [issue form](https://github.com/github/docs/issues/new/choose).

### Pull Request Process

1. Ensure any install or build dependencies are removed before the end of the layer when doing a  build.
2. Update the README.md with details of changes to the interface, this includes new environment  variables,
   exposed ports, useful file locations and container parameters.
3. Increase the version numbers in any examples files and the README.md to the new version that this
   Pull Request would represent. The versioning scheme we use is [SemVer](http://semver.org/).
4. You may merge the Pull Request in once you have the sign-off of two other developers, or if you 
   do not have permission to do that, you may request the second reviewer to merge it for you.

</div>
