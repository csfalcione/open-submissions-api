# OpenSubmissions

To start the backend:

  * Install dependencies with `mix deps.get`
  * Start the database with `docker-compose up -d`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now the server should be running on http://localhost:4000/

All of the endpoints are documented in Postman  [![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/e4825f3b14069e4ad6cb)

As of now, users can create problems, define test cases, and execute arbitrary code written in C, Java, and Python3 against those test cases. A test case is defined as having a textual input, and an expected textual output. A solution must read its input from stdin, and write its output to a file whose name is given by the RESULT_FILE environment variable. Any stdout will be collected and returned to the user (for debugging and testing).

For example, one might create a problem isPalindrome of the form f: string -> boolean with a helpful description describing palindromes, then add some of the following test cases:
- "abc" => "false"
- "racecar" => "true"
- "abcba" => "true"
- "abccba" => "true"
- "abccb" => "false"
- "hello" => "false"

An example solution, written in python, might look like:
```python
from os import environ
from sys import stderr

def main():
    filename = environ.get('RESULT_FILE')
    if filename is None:
        print("no RESULT_FILE environment variable", file=stderr)

    inputString = input()
    result = isPalindrome(inputString)
    result = repr(result).lower()

    with open(filename, 'w') as result_file:
        result_file.write(result)

def isPalindrome(string):
    return string == string[::-1]


main()
```

You'll notice however, that it would be ideal if everything other than the isPalindrome function could be generated from a description of the problem, allowing the student to skip the boilerplate (TODO).
