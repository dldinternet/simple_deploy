[![Build Status](https://secure.travis-ci.org/intuit/simple_deploy.png)](http://travis-ci.org/intuit/simple_deploy)

Simple Deploy is an opinionated gem that helps manage and perform directed deployments to AWS Cloud Formation Stacks.

Prerequisites
-------------

* Ruby version 1.9.2 or higher installed.
* AWS account access key and secret key.

Installation
------------

Install the gem

```
gem install simple_deploy --no-ri --no-rdoc
```

Create a file **~/.simple_deploy.yml** and include within it:

```
environments:
  preprod:
    access_key: XXX
    secret_key: yyy
    region: us-west-1
```

Documentation
-------------

For more information, please view the [Simple Deploy Wiki](https://github.com/intuit/simple_deploy/wiki).

Contributing
-------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
