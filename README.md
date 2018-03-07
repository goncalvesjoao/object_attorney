# Object Attorney
This gem allows you to create **use cases**, **services** or **form objects** with ActiveModel validations and keep your model clean.

[![Code Climate](https://codeclimate.com/github/goncalvesjoao/object_attorney/badges/gpa.svg)](https://codeclimate.com/github/goncalvesjoao/object_attorney)
[![Test Coverage](https://codeclimate.com/github/goncalvesjoao/object_attorney/badges/coverage.svg)](https://codeclimate.com/github/goncalvesjoao/object_attorney/coverage)
[![Build Status](https://travis-ci.org/goncalvesjoao/object_attorney.svg?branch=master)](https://travis-ci.org/goncalvesjoao/object_attorney)
[![Gem Version](https://badge.fury.io/rb/object_attorney.svg)](https://badge.fury.io/rb/object_attorney)

## 1) Basic Usage
```ruby
class User < Struct.new(:title, :first_name, :last_name)
end
```

```ruby
class UserValidator < ObjectAttorney::Base
  validates_presence_of :first_name

  validate :last_name_present

  def last_name_present(user)
    return if user.last_name.present?

    user.errors.add(:last_name, :blank)
  end
end
```

```ruby
@user = User.new

UserValidator.new(@user).valid? # false

@user.errors.messages # { first_name: ["can't be blank"], last_name: ["can't be blank"] }
```

## 2) Custom Usage
```ruby
class User < ActiveRecord::Base
end
```

```ruby
class UserValidator
  include ObjectAttorney

  defend :user

  validates_presence_of :first_name, if: :last_name_is_present

  attr_accessor :user

  def initialize(user)
    @user = user
  end

  def last_name_is_present(user)
    user.last_name.present?
  end
end
```

```ruby
@user = User.new(last_name: 'Snow')

UserValidator.new(@user).invalid? # true

@user.errors.messages # { first_name: ["can't be blank"] }
```

## 3) Installation

To install Object Attorney on the default Rails stack, just put this line in your Gemfile:
```ruby
gem 'object_attorney'
```

Then bundle:
```
$> bundle
```

and after that, I'd advise you to lock the gem's version in your Gemfile
