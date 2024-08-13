if (DEFINED ENV{HOMEBREW_PREFIX})
    set(HOMEBREW_PREFIX $ENV{HOMEBREW_PREFIX})
else ()
    message(FATAL_ERROR "HOMEBREW_PREFIX environment is not set!")
endif ()

set(ENV{GOPROXY} "https://goproxy.cn,direct")
