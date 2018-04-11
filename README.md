# Enrico Teotti's Jekyll homepage

This is a repository I use to publish update to my personal blog.

The underlying technology is a Ruby gem called Jekyll to generate static HTML and CSS from dynamic templates. Learn more about [Jekyll](https://jekyllrb.com/).

I created two docker-compose services to:
* run the blog preview locally
* build the blog for production

## Steps to develop

* `docker build -t teottidotcom .`
* `./docker/previewBlog.sh`

## Steps to publish

* `./docker/buildForDeploy.sh`
* `cd _deploy`
* **ONLY FIRST TIME** `git init . && git remote add origin https://github.com/octocat/Spoon-Knife`
* `cd ..`
* now the deploy directory is ready to deploy run: `./script/deploy.sh`

Once the content of that directory is to github master branch then github pages will pick the changes up in a few seconds.
