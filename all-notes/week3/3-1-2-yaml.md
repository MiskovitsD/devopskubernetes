# Tool

Any IDE or advanced text editor supports handling YAML files. 
We will use today an online validator: https://www.yamllint.com/

# Basic types

3 simple types are available: number, text, logical value.

Try out these values on the website:

```
5
"hello"
'hello'
'hello "there"'
"hello \"there\""
hello 'there "Michael"
true
"true"
```

# Object

Fields of an object, where all the fields are on root level, without any nested objects:

```yaml
fieldOne: valueOne
fieldTwo: “valueTwo”
fieldThree: 3
fieldFour: true
fieldFive: “true”
spaces are allowed: both places
```

We can also create objects like in JSON, if we want to put something in one line:

```yaml
{element: value, something: else}
```

# Comments

We can put comments anywhere. Put one in a new line, and on at the end of a line as a comment:

```yaml
# This is a comment in YAML!
```

# Nested objects

We can do nested objects with a colon, and with indenting everything below that. 
Either 2 or 4 spaces (or tabs) are good for indentation, but it must be consistent.

```yaml
fieldOne: value
objectField:
  fieldOfObject: true
  anothetObject:
    fieldOfInnerObject: 2
```

# Array or list

It can be done similarly like an object, but each list element must have a dash at the start.

In this example, we have an array on the root level:

```yaml
- one
- two
- three
```

In this example, we have an array as a field of an object:

```yaml
text: value
object:
  field: true
  list:
  - 1
  - 2
```

Note, that the dash can also be indented:

```yaml
text: value
object:
  field: true
  list:
    - 1
    - 2
```

Also note, that if we want to put an array in as one list, we can do it similarly, like in a JSON:

```yaml
rootField: text
object:
  field: true
  list: [1, 2]
```

# Multi-line strings

Sometimes we might want to put in long, multi-line strings into a YAML file. This can be done like this, yet again, the indentation will be important to us:

```yaml
longText: |-
  this is a text
  a multi-line text!
object:
  longTextInObject: |-
    this is another text
    this time inside an object!
  field: 3
```

