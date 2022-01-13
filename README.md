# Adara CRM

## Prerequisites

The setups steps expect following tools installed on the system.

- Gitlab
- Ruby [2.6.6]
- Rails [5.2.2]
- Postgres

#### 1. Check out the repository

```bash
git clone git@gitlab.com:coatilabs/adara-crm/adara-crm.git
```

#### 2. Create .env.example.yml file

Copy the sample .env.example file and edit the configuration as required.

```bash
cp .env.example .env
```

#### 3. Create and setup the database

Run the following commands to create and setup the database.

```bash
bundle exec rails db:create
bundle exec rails db:migrate
bundle exec rails db:seed
```

#### 4. Start the Rails server

You can start the rails server using the command given below.

```bash
bundle exec rails jobs:work
bundle exec rails s
```

And now you can visit the site with the URL http://localhost:3000


### Setup Testing

This article may help you this a Ubuntu setup.
- https://www.gregbrisebois.com/posts/chromedriver-in-wsl2/

You need to do this even if you have Chrome installed in Windows already.

Dependencies:
```bash
sudo apt-get update
sudo apt-get install -y curl unzip xvfb libxi6 libgconf-2-4
```

Chrome itself:
```bash
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo apt install ./google-chrome-stable_current_amd64.deb
```

Ensure it worked:
```bash
google-chrome --version
```

Find the URL of the ChromeDriver version that matches your Chrome version on the ChromeDriver website (https://chromedriver.chromium.org/)

Download, unzip, and put it in your bin directory:
```bash
wget https://chromedriver.storage.googleapis.com/X.X.X.X/chromedriver_linux64.zip
unzip chromedriver_linux64.zip
sudo mv chromedriver /usr/bin/chromedriver
sudo chown root:root /usr/bin/chromedriver
sudo chmod +x /usr/bin/chromedriver
```

Double check it worked:
```bash
chromedriver --version
```

If you had previously installed ChromeDriver in Windows and were using it in WSL from the Path, make sure you aren’t pointing to that one anymore:
```bash
which chromedriver # should be /usr/bin/chromedriver
```
