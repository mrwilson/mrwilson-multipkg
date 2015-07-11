# multipkg

  [![Build Status](https://travis-ci.org/mrwilson/mrwilson-multipkg.png?branch=master)](https://travis-ci.org/mrwilson/mrwilson-multipkg)

This is the multipkg module.

# Supports

 * rpm
 * apt

# Example

```
multipkg { 'project-utils':
  packages => ['foo', 'bar', 'baz']
  }
```

Also supports yum group packages using Group-Id. Use `yum -v groupinfo "Package Name"` to get Group-Id.

```
multipkg { 'base-packages':
  packages => ['foo', '@bar', '@baz']
  }
```

## License

MIT

## Support

Please log tickets and issues on [Github](https://github.com/mrwilson/mrwilson-multipkg)
