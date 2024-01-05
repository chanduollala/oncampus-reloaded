# Use the official Ruby image
FROM ruby:3.2.2

# Set the working directory in the container
WORKDIR /usr/src/oncampus

# Copy Gemfile to the container
COPY Gemfile docker-compose.yml ./

# Install gems
RUN bundle install

# Copy the rest of the application to the container
COPY app/ ./app/
COPY bin/ ./bin/
COPY db/ ./db/
COPY config/ ./config/
COPY lib/ ./lib/
COPY config.ru ./config.ru
COPY Rakefile ./Rakefile

# Expose the port your Rails app runs on
EXPOSE 3000

#CMD ["cd"

# Start the Rails server
CMD ["rails", "server", "-b", "0.0.0.0", "-e", "production"]

