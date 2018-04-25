# `retractcheck`

[![Travis build status](https://travis-ci.org/chartgerink/retractcheck.svg?branch=master)](https://travis-ci.org/chartgerink/retractcheck)

Check DOIs in a paper for being retracted by running your manuscript through `retractcheck`. This is an R package that builds on the API of [Open Citations](http://opencitations.com) ([also an open source project](https://github.com/fathomlabs/open-retractions)). 

The original inspiration for this package can be found [in a tweet by @PaolaPalma](https://twitter.com/PaoloAPalma/status/976545221268815872) and the origin of the name in [this tweet by @MarkHoffarth](https://twitter.com/MarkHoffarth/status/976548240672870405) :fire:

__Note that this repository will be moved to the [Liberate Science](https://github.com/libscie) account upon release__

## Example

INSERT GIF LATER

## Installation

```R
devtools::install_github('chartgerink/retractcheck')
```

## Limitations

If the `retractcheck` package does not return any hits for retracted references, please note that the result is only as good as the data made available on this. A great research project would be checking this, which can be discussed 

## License

[MIT](LICENSE.md)

## Code of conduct

This project is released with a [Contributor Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms. We welcome you with open arms if you are mindful and respectful of differences. You might not always understand another person's perspective; acknowledging that other people's feelings or perspectives are valid regardless of your understanding is prerequisite number one to being both mindful and respectful. We will not consider contributions if they are not done in a respectful manner, no matter how "genius" they might be.

## Contributor guidelines

* Read the Code of conduct
* Maintainers sign commits
* All contributions and pull requests should only be made if you agree to license your contribution under MIT
