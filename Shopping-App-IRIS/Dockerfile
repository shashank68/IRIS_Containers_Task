FROM ruby:2.5.1-stretch

RUN mkdir /railsapp

WORKDIR /railsapp
COPY Gemfile /railsapp/Gemfile
COPY Gemfile.lock /railsapp/Gemfile.lock
RUN bundle install
COPY . /railsapp
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && apt install -y nodejs

COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT [ "entrypoint.sh" ]
EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]