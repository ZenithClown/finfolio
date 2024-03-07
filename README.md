<h1 align = "center">
	Flask Template <br>
	<sub><b><i>(python, docker, rest-api, flake8)</i></b></sub> <br>
	<a href = "https://www.linkedin.com/in/dpramanik/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/linkedin.svg"/></a>
	<a href = "https://github.com/ZenithClown"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/github.svg"/></a>
	<a href = "https://gitlab.com/ZenithClown/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/gitlab.svg"/></a>
	<a href = "https://www.researchgate.net/profile/Debmalya_Pramanik2"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/researchgate.svg"/></a>
	<a href = "https://www.kaggle.com/dPramanik/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/kaggle.svg"/></a>
	<a href = "https://app.pluralsight.com/profile/Debmalya-Pramanik/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/pluralsight.svg"/></a>
	<a href = "https://stackoverflow.com/users/6623589/"><img height="16" width="16" src="https://unpkg.com/simple-icons@v3/icons/stackoverflow.svg"/></a>
</h1>

<p align = "justify">A simple <i>flask-template</i> for REST-API design and implementation. Please include the <a href = "https://github.com/ZenithClown/flask-docker-template/tree/master">Template Link</a> in your design. Template includes <code>.gitignore</code> and <code>.gitattributes</code> related to python and flask-api model. You can also update/change/delete <code>LICENSE</code> as required. Other files are related to <code>docker</code> and <code>flake8</code> (code linting) is included with basic setup. The template is built on GitHub, thus <code>.github</code> directory is included with issue template, and workflows directory.</p>

**NOTE:** some optional usage, specifications, and helpful links are as below:
  1. You can add GitHub Repository Badges from [Shields IO](https://shields.io/) - if this is a Public Repository;
  2. TAB (size = 4) has been used for indentation.
  3. `.github/workflows` is added however, it is recomended that you create your own workflows either using **GitHub Actions** or on your own.
  4. Basic `docker` files are added for convention, modify it as per requirement. Recomended to delete the file, if not required.
  5. The repository uses `markdown` instead of `rich text format`, so make necessary changes to file extension/type as required.

## Quick Start Guide
<p align = "justify">Introduced in 2019, users can now create a repository from templates in GitHub. To do this, simply head over to any repository settings and enable "Template Repository" from the Options Menu. When creating a <i>new repository</i> from this template, you can just click on <b><code>Use this template</code></b> available in this repository (refer the picture below).</p>

<img alt = "use_this_template_demo" src = "./assets/use_this_template_demo.png">

### Creating a NEW Repository from Template
<p align = "justify">Template Repository is not limited to GitHub, and you can setup your own local-file structure for the same. The following describes the usage of <code>rsync</code> which is available in most linux distros, <a href = "https://linux.die.net/man/1/rsync">more information on rsync</a>.</p>

```bash
# Note the use of rsync
rsync -rh ~/source/directory /destination/directory
```

## Setup Information
<p align = "justify">Configure the application by setting <code>ENVIRONMENT VARIABLES</code> as required. Sample variables are provided in <code>.env.bkp</code>, however for production grade application is is recomended that you set them at <code>$PATH</code>. Start the application using <code>python manage.py</code> which serves the port <code>0.0.0.0:5000</code> by default.</p>
