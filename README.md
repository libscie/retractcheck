# `retractcheck` <img src="tools/images/retractcheck_hex.png" align="right" height="150" />

[![Build Status](https://travis-ci.org/libscie/retractcheck.svg?branch=master)](https://travis-ci.org/libscie/retractcheck)

Check DOIs in a paper for being retracted by running your manuscript through `retractcheck` in R or using the [Shiny app](https://frederikaust.shinyapps.io/retractcheck_shinyapp/) in your browser. This R package builds on the API of [Open retractions](http://openretractions.com) ([also an open source project](https://github.com/fathomlabs/open-retractions)). 

The original inspiration for this package can be found [in a tweet by @PaolaPalma](https://twitter.com/PaoloAPalma/status/976545221268815872) and the origin of the name in [this tweet by @MarkHoffarth](https://twitter.com/MarkHoffarth/status/976548240672870405) :fire:

## Example

INSERT GIF LATER

## Installation

```R
devtools::install_github('libscie/retractcheck')
```

Please note that the dependency on `textreadr` may fail if you don't have the necessary software for that. If installation fails, try `install.packages('textreadr')` and see what errors it gives. It may look like this

```R
Configuration failed because poppler-cpp was not found. Try installing:
 * deb: libpoppler-cpp-dev (Debian, Ubuntu, etc)
 * On Ubuntu 16.04 or 18.04 use this PPA:
    sudo add-apt-repository -y ppa:opencpu/poppler
    sudo apt-get update
    sudo sudo apt-get install -y libpoppler-cpp-dev
 * rpm: poppler-cpp-devel (Fedora, CentOS, RHEL)
 * csw: poppler_dev (Solaris)
 * brew: poppler (Mac OSX)
```

## Limitations

If the `retractcheck` package does not return any hits for retracted references, please note that the result is only as good as the data made available on this.

## License

[MIT](LICENSE.md)

## Code of conduct

This project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms. We welcome you with open arms if you are mindful and respectful of differences. You might not always understand another person's perspective; acknowledging that other people's feelings or perspectives are valid regardless of your understanding is prerequisite number one to being both mindful and respectful. We will not consider contributions if they are not done in a respectful manner, no matter how "genius" they might be.

## Contributor guidelines

* Read the Code of conduct
* Maintainers sign commits
* All contributions and pull requests should only be made if you agree to license your contribution under MIT
