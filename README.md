# Heighliner

Heighliner is a tool that allows you to describe your web application using a Steerfile.

This removes the guesswork of setting up a web application for development and gives teams an edge by allowing new developers on a system to hit the ground running, as well as propagate any changes in settings to other developers via source code.

The Steerfile gives you an immense amount of control on how you want your application set up.

# Dependencies

Heighliner depends on Docker

# Installation

## Installation (Docker)

Simply add the following line to your `.bashrc` or `.bash_profile` or '.zshrc'

```
alias heighliner='docker run --pull=always --rm -ti -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.heighliner:/root/.heighliner -v `pwd`:`pwd` -e _HEIGHLINER_USER_HOME=$HOME -e _HEIGHLINER_POS=docker -e CONTEXT_DIR="`pwd`" davidsiaw/heighliner'
```

Or if you use fish

```
function heighliner
  docker run --pull=always --rm -ti -v /var/run/docker.sock:/var/run/docker.sock -v $HOME/.heighliner:/root/.heighliner -v (pwd):(pwd) -e _HEIGHLINER_USER_HOME=$HOME -e _HEIGHLINER_POS=docker -e CONTEXT_DIR=(pwd) davidsiaw/heighliner $argv
end
```

Confirm it is working by running

```
heighliner -h
```

## Installation (Plain)

Execute:

```
$ bundle install
```

Or install it yourself as:

```
$ gem install specific_install
$ gem specific_install -l https://github.com/davidsiaw/heighliner
```

## Building the docker container

You can build the Heighliner image on your machine if you want

Simply clone the repo and run 

```
cd heighliner
bundle
docker build -t davidsiaw/heighliner . 
```

And then

# Usage

You'll need a Dockerfile and a Steerfile. The Steerfile should be placed in the project root directory, with contents like this:

```ruby
# Example Steerfile for a Rails app

dockerfile "Dockerfile"

db "mysql:5.6",
  port: 3306,
  data_dir: "/var/lib/mysql",
  params: "-e MYSQL_ROOT_PASSWORD=test123",
  commands: ""

app_params "-e DATABASE_URL=mysql2://root:test123@<%= db_container_name %>"

expose "9000"
db_reset_command "bin/rails db:reset"
```

```dockerfile
FROM ruby:alpine

COPY . /app
RUN apk update && apk add build-base
RUN gem install bundler
RUN bundle install

EXPOSE "3000"

CMD ["sh", "-c", "rails -b 0.0.0.0 -p 3000"]
```

Then go to your repo's root folder and go

```sh
bundle exec heighliner init myapp
bundle exec heighliner up
```

Once its done, simply

```sh
open http://myapp.lvh.me
```

And enjoy previewing your app!

## More documentation

You can find even more documentation in https://davidsiaw.github.io/heighliner.

If you wish to read a HTML version of this documentation you can go:

```
cd docs
bundle install
bundle exec weaver
```


## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Ez dev setup

```
alias heighliner='docker run --rm -ti \
  -v /Users/davidsiaw/programs/heighliner/exe/heighliner:/usr/local/bundle/bin/heighliner \
  -v /Users/davidsiaw/programs/heighliner/lib:/usr/local/bundle/gems/heighliner-0.8.3/lib \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v $HOME/.heighliner:/root/.heighliner \
  -v `pwd`:`pwd` \
  -e _HEIGHLINER_USER_HOME=$HOME \
  -e _HEIGHLINER_POS=docker \
  -e CONTEXT_DIR="`pwd`" \
  davidsiaw/heighliner'

```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/davidsiaw/heighliner. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Heighliner project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/davidsiaw/heighliner/blob/master/CODE_OF_CONDUCT.md).
