# Object Attorney


[![Code Climate](https://codeclimate.com/github/goncalvesjoao/object_attorney/badges/gpa.svg)](https://codeclimate.com/github/goncalvesjoao/object_attorney)
[![Test Coverage](https://codeclimate.com/github/goncalvesjoao/object_attorney/badges/coverage.svg)](https://codeclimate.com/github/goncalvesjoao/object_attorney/coverage)
[![Build Status](https://travis-ci.org/goncalvesjoao/object_attorney.svg?branch=master)](https://travis-ci.org/goncalvesjoao/object_attorney)

## 1) Basic Usage
```ruby
class User < Struct.new(:title, :first_name, :last_name)
end
```

```ruby
class UserValidator < Struct.new(:user)
  include ObjectAttorney

  defend :user

  validates_presence_of :first_name
end

# OR

class UserValidator < ObjectAttorney::Base
  validates_presence_of :first_name
end
```

```ruby
@user = User.new

UserValidator.new(@user).valid?

@user.errors.messages # { first_name: ["can't be blank"] }
```
