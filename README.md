# Enrico Teotti's Jekyll homepage

This is a repository I use to publish update to my personal blog.

The underlying technology is a Ruby gem called Jekyll to generate static HTML and CSS from dynamic templates. Learn more about [Jekyll](https://jekyllrb.com/).

I created two docker-compose services to:
* run the blog preview locally
* build the blog for production

## Steps to develop

Start `docker-compose up`, edit the source files check the browser on port 4000.

## Steps to publish

* run `docker-compose up build_pages_for_deploy --scale 1`
* this should create a `_deploy` directory
* `cd _deploy`
* `git init .`
* `git remote add origin https://github.com/octocat/Spoon-Knife`
* `cd ..`
* now the deploy directory is ready to deploy run: `./script/deploy.sh`

Once the content of that directory is to github master branch then github pages will pick the changes up in a few seconds.
