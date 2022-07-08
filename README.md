# mulle-objc-compat

#### 🍏 Compatibility layer with Apple Objective-C runtime functions

This library maps
[Apple runtime](//developer.apple.com/documentation/objectivec/objective_c_runtime?language=objc)
functions to their [mulle-objc](//mulle-objc.github.io) counterparts.
This makes porting of existing programs that use Apple runtime functions easier.
If you can get by with the limited set of functions, these functions are
preferable to use over their mulle-objc counterparts for the sake of portability
and familiarity.


| Release Version
|-----------------------------------
| ![Mulle kybernetiK tag](//img.shields.io/github/tag/mulle-objc/mulle-objc-compat.svg) [![Build Status](//github.com/mulle-objc/mulle-objc-compat/workflows/CI/badge.svg?branch=release)](//github.com/mulle-objc/mulle-objc-compat/actions)



> #### Mental model
>
> This library
>
> * does not include any other runtime than mulle-objc-runtime.
> * does not define any functionality that is not part of the Apple runtime
> * does not implement everything that's in the Apple runtime
>

## Limitations

* This library hasn't been scrutinized for thread-safety.
* Some functionality is missing that mulle-objc does not support. E.g. "weak variables".
* Message sending via `objc_msgSend` uses the [mulle-objc MetaABI](//www.mulle-kybernetik.com/weblog/2015/mulle_objc_meta_call_convention.html) and therefore is only compatible in the case, where there is only one pointer sized parameter and a pointer sized return value.
* The library must be compiled with mulle-clang (since the multiverse changes)


## Add

This is project is a [mulle-sde](//mulle-sde.github.io/) project.
Add it with:

```
mulle-sde dependency add --objc --github mulle-objc mulle-objc-compat
```

## Author

[Nat!](//www.mulle-kybernetik.com/weblog) for
[Mulle kybernetiK](//www.mulle-kybernetik.com) and
[Codeon GmbH](//www.codeon.de)
