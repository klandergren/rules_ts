"""Mirror npm registry metadata for the typescript package

Update with: 
curl --silent https://registry.npmjs.org/typescript | jq '[.versions[] | select(.version | test("^[0-9.]+$")) | {key: .version, value: .dist.integrity}] | from_entries'
"""

# Versions should be ascending order so TOOL_VERSIONS.keys()[-1] is the latest version.
TOOL_VERSIONS = {
    "0.8.0": "sha512-t4DYxzL6Gt3+TRuJXtmh+3KfcY5iSM8J4lzUgfQkTOr78xFbmor79x/dQEGMaiqO2HJBbFGO3RlIaxPzpP5JMA==",
    "0.8.1": "sha512-/cfem275IES0o4/zVD1UmXfE3k5j2OAianSI2Oa1gYzWhAJ44OjNlXv3LVIj5EZ0fgks/XBtzp8aXVsaYILTVg==",
    "0.8.2": "sha512-rc182AVnpWJ2d6mSAjzALdgEZMJqtsAwPjogw7ch8NRa7iTD8vGG2YoZto1R5Bkt5xCXFcg5SrkRenYtI+poHQ==",
    "0.8.3": "sha512-42GP2FBgk+/q8Y0MRt0vJoWx6I7ADAKBTnz7gK++gwQtzC3h54Yltqb8z+EFozZ4OHhz6uwLmXFthCn4oDOGxg==",
    "0.9.0": "sha512-8sm4aL114AiqdtQ98vnTv4xJ6iG0ENs5LLP2ve3fcRKoCSPfA62MpjoKDW3hyfxuSeyw2kZvrqrYL0dvi8EUYg==",
    "0.9.1": "sha512-F6shwhZfSPDxbLBi7yLelWZktA80l9BC6Kv8xLA5GOCrPRqgAC8KAYdA3Ndstb8VREnGhVt2ZAtfODqBmpszog==",
    "0.9.5": "sha512-TEfGbLyu9hJDS3WOVKSyJfHWtANlEHVyKDEbc7L3uQatBVrDlNj0/VfTOsq8cA51NoAFZBsv8I9XpIlC39ItPw==",
    "0.9.7": "sha512-0ebvZOlaBlGiSE6VCXXWAvM2EZ6tCzwGCKGoj8eU5DHiXQgLu35dRlsSz/duoa8+DsP8dZa3w8EVY1XA1XXJuw==",
    "1.0.0": "sha512-ZCBoo2eOiZIBgrTaxUVc6ObslTDmV6KHzr+mMnQaHw0LfJoBPFGGx3tiw3LpbstM0/shecjT8obvN6ShFSkAYw==",
    "1.0.1": "sha512-YrXpvrihkXMrJIWdChdua78XxhamZuCAWfKSpj2lPyACX7FtbwJL2SocH++yWe/VPTrVX0UZ3x6xHIyuQXrIOw==",
    "1.3.0": "sha512-udSigEGeUezznWiLfG43S8yw8CbiuVsfej4swPrXSdNiDnwrT5pUGg1DstrMvDBi84xGqnq0QyAp3kEUtVkLTA==",
    "1.4.1": "sha512-ZmFU3h/TzPofFlcMe8stHEBdrC/U0Mzs+s91OXEFKLMjjfPM1v/udHkvR0A4FLyjELdtRR8fgmjB/GeKBbW6UA==",
    "1.5.3": "sha512-Wux4s7AfnapjkjEQ9gWRqKBAon83Zott4rr8q/QNEyBz8gT5u88O/HbjMifu1ad5GIm9q0vqEG1Pvn20/rFxKQ==",
    "1.6.2": "sha512-FC5jZDS/XjVKZefJbSv8CCHo4973XnxhBxRUAh9i6rKktMOuMk//celFsFt8cP6xE+IJQMfNPsbi5LH7DkllQA==",
    "1.7.3": "sha512-374JIkIfXAJXaFnmZoeeE5FwMsRwaHzVf6UvcsZnDEfatuINfCvAtaFOmgt1bWcfaeO6Kw1DDvmA7lWNv05roA==",
    "1.7.5": "sha512-kxhllC9x9Cplc0CPWCBU6thg7ZT1SfISG43B5ji4CItrJ3+Et6CscIKWroF+E6a9MhsqmmTbRCkAA0/vhDyt5A==",
    "1.8.0": "sha512-HwH1YDy07AF1+TNJN3+tZ9BxEahSWUBqlydC9Q0rEkNMTx11TDuYqAuXdNCxXOg8jlGW5LWKslD4xkOgAS2TFg==",
    "1.8.2": "sha512-Wxg4z87M0Sw0hZLS786UgXVwj2V8xiQWXdmweFPgPXzSREgDKSZ60rJ+JFOy+rqbe7i7hAReZkY940/N1r/bjQ==",
    "1.8.5": "sha512-hzQmMgPhYbtwP61juMNJepg8Ej3N0ef++c91CDbh0HLqclcR00G41pxIDc56GgNxxCJiBJ+VTgmcr6sDPNnXuQ==",
    "1.8.6": "sha512-YFAalD4B6wG4+Ed5KfXRLFJ/fg9dYpW1M/BExFzzGwWZjaHvsdkNGrCPSBQKfnLPlag7cxAklO9v0aBqYsdoJw==",
    "1.8.7": "sha512-cyQ88faHXPgtrVpfwfKWY8g7XwWyQBwsKhX4Imn3mYSWceG+auqTU5XEm6/HeUZK/+UXGw6fpkJbVKIPm9hyQw==",
    "1.8.9": "sha512-orKTYFUBnvozvQJqEreF6dA55Y334PtFbUJPkyqCwThYcnv7GnDaVwEQ0obHy9f9PDsm5x4ZTPEeJuLtTXqBXg==",
    "1.8.10": "sha512-amAjhGr2ZKUcd3OpqmSWbyz57bveJcwLdVp4XY31zR3Lylq0ZG8MHAX4IpoJ5AypkdkKkMRRVoqY6lKWrR9uPQ==",
    "2.0.0": "sha512-qb9m9Zbxuk5AGS0YS+sbmIUjX6Y6xka5cQw+tL0V/7CFAr/8obG2CwDxZ7Ky8CFfclL8xCTUppeqDUkyBC7dGg==",
    "2.0.2": "sha512-eiTFO9Pmm6GAv3fnBQXAun+siVNWTlXDKlFOAwGlzRNLIWGKOfIv/jSkNL9Wo8K3+x5fyHAvOd16e38RSQB99g==",
    "2.0.3": "sha512-VMzzasFNZ8NAp/t4UQeOIAa6x2c3XXB6+URGufGpPPRyWm197B0dPu9S7t4MGhXCv7oCDvo+Hx/qF7LLI8dOjw==",
    "2.0.6": "sha512-sGCGLHTuI6gQO1A7mqB0pIh+fQXwIcGZ6VbMaRm5VuGrZAAr4IMBmGbfuFJgK7SouPpUVGL+WxDAA+8Hx+a/JA==",
    "2.0.7": "sha512-eNpNxW9ttTDixAYbwl7sf1J3u8Ij2jCaUMQBR/37iDGIrgEBuTPAwvIr/lTXxOqxEcBeqM/QaPW6NnSFYjfRjA==",
    "2.0.8": "sha512-XnJdDFyT1mw2S432I/3RaOGO6kfdspsITNg9YgwXXsSyIpqQRhZOhosklgteCNfbYJK+/y7IWsfxunNYQiUihA==",
    "2.1.1": "sha512-BUQIyoprrW/20drNowXsbbxnCpMhmcXwJW1FpvabWa5U4pXMRNDF3Bj4TPYmhNNkIXqmWmBa02e/8O24Z6UVMA==",
    "2.0.9": "sha512-WCvqhPa/xS/F4C3a5JKfuA8tGNYu1sib1njJQv/cTrHvMqjFVfR7HqrR+qGDbVRWelPzCSJHAN1cwGlFxOZHdQ==",
    "2.0.10": "sha512-A1McfqUmeBy/8UpP106D7ShCZ3/C6w1muFGDEQ+2EhvwHcWC4uduBntOM8lXlHWOnWOA1vHo48lKe9ZDrJZsJg==",
    "2.1.4": "sha512-XMTszCqW84ik3mFyO7aOmkbiryZ0J7H9bQwAHD0NhvC2T7XlocVIPwYrS4DZ73H53ETTBXMjgQLGdx7uwxsWRA==",
    "2.1.5": "sha512-OHCRjnoBo9+v90Afp4lidM1gHsx4jrIa6M+M2R/RDxn3sUfNGy6lP/TmgD9D56ebthSu18ikELqJt9Gov3FDmA==",
    "2.2.0": "sha512-JHeXepbsIG8VMFnj7ZjQ4/iVATRau86UOeZdAvYtd88uqOz/9E0h4TW384wlnqTHSMyt3FcSkMEE3n2s5Q3n2w==",
    "2.1.6": "sha512-K3UOLVZbmb0mXh2dNfvY20u5PSqiyyhDHcCboXVRsmLavjbuZocp9D3fPdtAWZmdQ1UERwxqLeGmXDSQsWcL8g==",
    "2.2.1": "sha512-B5nx5IYw1gmtvzMtwTGoKTep3640E0XCbH4kRhuT52poZ/K9Omvgx+GfwHXfO2S8pd00FaJIs+uq4zMq6QXH8Q==",
    "2.2.2": "sha512-ZQXTJ7IcU5Yg8Mz8VzVFDrguzIDpRxNlD8yjowh1F0cbruhWnd92YJ/c6gHjopRINwhgpe5bDx7fOD6nAagwmQ==",
    "2.3.0": "sha512-41KiJx7Kr9NPbDyVA6rG2IZy85YQlQal0q4/pe5Q6CzFMOsQwTal4+N0nwZ3AdQ7Uz65L21a+1TcLrzFdiDypw==",
    "2.3.1": "sha512-8yv0VYy+SqEf5m1+atgtLat4lwKGHZRnINqSNt5wamBNSUdLMSW+ckYh5dMxwtI2n0nMEwgbeVVBm7xT3h1kEA==",
    "2.3.2": "sha512-k33X5cB289um3zfG9TvmvyqnniutYr9pSLq1hvIND7eW8sEhuzJQAG9JYis5TZOtf+JAKJ+gR6F/vHq/KYD3eQ==",
    "2.3.3": "sha512-/AVo6DultTMR1uBhJV8Rzs4HKqfUR33dREsFnzP6BAFz1o/v9guifnoj3+xJIEHmxZlBjxuF48orvU1n6JmPlg==",
    "2.3.4": "sha512-+3YA3hpUsl9lWPPsPQshiyXvU9EgJhvMoG2V74b6D2BddGePqRbQWNztTvpoUjlpf+3TUIL14C4Cad4QNvOVfQ==",
    "2.4.0": "sha512-jFRndmgzNIBgazQZ6f6mrnjPhgVyh+35yrHtxoCQZJkD8zaUs1MqpaI53SGtuLV8MW1K62dm4EYk9A2tIDGOng==",
    "2.4.1": "sha512-3O/A1TbKiXlfWsBv+X9QpzylORsBSXZuIG8GMzYvPTFCrkc65iXKd4gAkVN/jmLgSkmdTDMRY5XyNu+DxZD7mQ==",
    "2.4.2": "sha512-a6qhFjx88CqXM92QX6e5zwbYavxaknEdFhh/ZrBmuHEP+r2ye102uvhCkWdian4u5Ee17W+8fAN7xtdM8KeQ7A==",
    "2.5.0": "sha512-O+kHENcJ+LDqMeToLMwGTvdhqMt5NuNwxs/IMaXID+Vfs6+JOej+MTNBOKtjStUQlMLDIT0Bp5cPO40b9MDXvA==",
    "2.5.1": "sha512-bjJnDzatnA5sYRquTyC8KZ+9bEHShTPBxLKRZ5SZMZWt3TZ92ANtKHcb6wlhK1oTckQc7YMFE2chtvITyXjjEg==",
    "2.5.2": "sha512-fExd1zMlJ/xQsNna/P9OsdN88hqBdBgKNhgqK4iewCe4BaIOAO9lK6/LDzwgmCFHCoQ14ULdxnLUmQjzu/Yybw==",
    "2.5.3": "sha512-ptLSQs2S4QuS6/OD1eAKG+S5G8QQtrU5RT32JULdZQtM1L3WTi34Wsu48Yndzi8xsObRAB9RPt/KhA9wlpEF6w==",
    "2.6.1": "sha512-tS2ybGoZKXHJqL+skWRSR0twQf3HmVGaMY8tNfOdi+tvlmPo+JN/ZYAdZuIBzGfPXxcAFhdp4fQM6LxqqU9cig==",
    "2.6.2": "sha512-L0QfAFYU8U/ucTqDptb0Hq67++OwqdSKDAAXmpaECxEkPOIpydxh4p0p9BRDG0kliZHFJBAWZDHR0nomxF/E7A==",
    "2.7.1": "sha512-bqB1yS6o9TNA9ZC/MJxM0FZzPnZdtHj0xWK/IZ5khzVqdpGul/R/EIiHRgFXlwTD7PSIaYVnGKq1QgMCu2mnqw==",
    "2.7.2": "sha512-p5TCYZDAO0m4G344hD+wx/LATebLWZNkkh2asWUFqSsD2OrDNhbAHuSjobrmsUmdzjJjEeZVU9g1h3O6vpstnw==",
    "2.8.1": "sha512-Ao/f6d/4EPLq0YwzsQz8iXflezpTkQzqAyenTiw4kCUGr1uPiFLC3+fZ+gMZz6eeI/qdRUqvC+HxIJzUAzEFdg==",
    "2.8.3": "sha512-K7g15Bb6Ra4lKf7Iq2l/I5/En+hLIHmxWZGq3D4DIRNFxMNV6j2SHSvDOqs2tGd4UvD/fJvrwopzQXjLrT7Itw==",
    "2.8.4": "sha512-IIU5cN1mR5J3z9jjdESJbnxikTrEz3lzAw/D0Tf45jHpBp55nY31UkUvmVHoffCfKHTqJs3fCLPDxknQTTFegQ==",
    "2.9.1": "sha512-h6pM2f/GDchCFlldnriOhs1QHuwbnmj6/v7499eMHqPeW4V2G0elua2eIc2nu8v2NdHV0Gm+tzX83Hr6nUFjQA==",
    "2.9.2": "sha512-Gr4p6nFNaoufRIY4NMdpQRNmgxVIGMs4Fcu/ujdYk3nAZqk7supzBE9idmvfZIlH/Cuj//dvi+019qEue9lV0w==",
    "3.0.1": "sha512-zQIMOmC+372pC/CCVLqnQ0zSBiY7HHodU7mpQdjiZddek4GMj31I3dUJ7gAs9o65X7mnRma6OokOkc6f9jjfBg==",
    "3.0.3": "sha512-kk80vLW9iGtjMnIv11qyxLqZm20UklzuR2tL0QAnDIygIUIemcZMxlMWudl9OOt76H3ntVzcTiddQ1/pAAJMYg==",
    "3.1.1": "sha512-Veu0w4dTc/9wlWNf2jeRInNodKlcdLgemvPsrNpfu5Pq39sgfFjvIIgTsvUHCoLBnMhPoUA+tFxsXjU6VexVRQ==",
    "3.1.2": "sha512-gOoGJWbNnFAfP9FlrSV63LYD5DJqYJHG5ky1kOXSl3pCImn4rqWy/flyq1BRd4iChQsoCqjbQaqtmXO4yCVPCA==",
    "3.1.3": "sha512-+81MUSyX+BaSo+u2RbozuQk/UWx6hfG0a5gHu4ANEM4sU96XbuIyAB+rWBW1u70c6a5QuZfuYICn3s2UjuHUpA==",
    "3.1.4": "sha512-JZHJtA6ZL15+Q3Dqkbh8iCUmvxD3iJ7ujXS+fVkKnwIVAdHc5BJTDNM0aTrnr2luKulFjU7W+SRhDZvi66Ru7Q==",
    "3.1.5": "sha512-muYNWV9j5+3mXoKD6oPONKuGUmYiFX14gfo9lWm9ZXRHOqVDQiB4q1CzFPbF4QLV2E9TZXH6oK55oQ94rn3PpA==",
    "3.1.6": "sha512-tDMYfVtvpb96msS1lDX9MEdHrW4yOuZ4Kdc4Him9oU796XldPYF/t2+uKoX0BBa0hXXwDlqYQbXY5Rzjzc5hBA==",
    "3.2.1": "sha512-jw7P2z/h6aPT4AENXDGjcfHTu5CSqzsbZc6YlUIebTyBAq8XaKp78x7VcSh30xwSCcsu5irZkYZUSFP1MrAMbg==",
    "3.2.2": "sha512-VCj5UiSyHBjwfYacmDuc/NOk4QQixbE+Wn7MFJuS0nRuPQbof132Pw4u53dm264O8LPc2MVsc7RJNml5szurkg==",
    "3.2.4": "sha512-0RNDbSdEokBeEAkgNbxJ+BLwSManFy9TeXz8uW+48j/xhEXv1ePME60olyzw2XzUqUBNAYFeJadIqAgNqIACwg==",
    "3.3.1": "sha512-cTmIDFW7O0IHbn1DPYjkiebHxwtCMU+eTy30ZtJNBPF9j2O1ITu5XH2YnBeVRKWHqF+3JQwWJv0Q0aUgX8W7IA==",
    "3.3.3": "sha512-Y21Xqe54TBVp+VDSNbuDYdGw0BpoR/Q6wo/+35M8PAU0vipahnyduJWirxxdxjsAkS7hue53x2zp8gz7F05u0A==",
    "3.3.3333": "sha512-JjSKsAfuHBE/fB2oZ8NxtRTk5iGcg6hkYXMnZ3Wc+b2RSqejEqTaem11mHASMnFilHrax3sLK0GDzcJrekZYLw==",
    "3.3.4000": "sha512-jjOcCZvpkl2+z7JFn0yBOoLQyLoIkNZAs/fYJkUG6VKy6zLPHJGfQJYFHzibB6GJaF/8QrcECtlQ5cpvRHSMEA==",
    "3.4.1": "sha512-3NSMb2VzDQm8oBTLH6Nj55VVtUEpe/rgkIzMir0qVoLyjDZlnMBva0U6vDiV3IH+sl/Yu6oP5QwsAQtHPmDd2Q==",
    "3.4.2": "sha512-Og2Vn6Mk7JAuWA1hQdDQN/Ekm/SchX80VzLhjKN9ETYrIepBFAd8PkOdOTK2nKt0FCkmMZKBJvQ1dV1gIxPu/A==",
    "3.4.3": "sha512-FFgHdPt4T/duxx6Ndf7hwgMZZjZpB+U0nMNGVCYPq0rEzWKjEDobm4J6yb3CS7naZ0yURFqdw9Gwc7UOh/P9oQ==",
    "3.4.4": "sha512-xt5RsIRCEaf6+j9AyOBgvVuAec0i92rgCaS3S+UVf5Z/vF2Hvtsw08wtUTJqp4djwznoAgjSxeCcU4r+CcDBJA==",
    "3.4.5": "sha512-YycBxUb49UUhdNMU5aJ7z5Ej2XGmaIBL0x34vZ82fn3hGvD+bgrMrVDpatgz2f7YxUMJxMkbWxJZeAvDxVe7Vw==",
    "3.5.1": "sha512-64HkdiRv1yYZsSe4xC1WVgamNigVYjlssIoaH2HcZF0+ijsk5YK2g0G34w9wJkze8+5ow4STd22AynfO6ZYYLw==",
    "3.5.2": "sha512-7KxJovlYhTX5RaRbUdkAXN1KUZ8PwWlTzQdHV6xNqvuFOs7+WBo10TQUqT19Q/Jz2hk5v9TQDIhyLhhJY4p5AA==",
    "3.5.3": "sha512-ACzBtm/PhXBDId6a6sDJfroT2pOWt/oOnk4/dElG5G33ZL776N3Y6/6bKZJBFpd+b05F3Ct9qDjMeJmRWtE2/g==",
    "3.6.2": "sha512-lmQ4L+J6mnu3xweP8+rOrUwzmN+MRAj7TgtJtDaXE5PMyX2kCrklhg3rvOsOIfNeAWMQWO2F1GPc1kMD2vLAfw==",
    "3.6.3": "sha512-N7bceJL1CtRQ2RiG0AQME13ksR7DiuQh/QehubYcghzv20tnh+MQnQIuJddTmsbqYj+dztchykemz0zFzlvdQw==",
    "3.6.4": "sha512-unoCll1+l+YK4i4F8f22TaNVPRHcD9PA3yCuZ8g5e0qGqlVlJ/8FSateOLLSagn+Yg5+ZwuPkL8LFUc0Jcvksg==",
    "3.7.2": "sha512-ml7V7JfiN2Xwvcer+XAf2csGO1bPBdRbFCkYBczNZggrBZ9c7G3riSUeJmqEU5uOtXNPMhE3n+R4FA/3YOAWOQ==",
    "3.7.3": "sha512-Mcr/Qk7hXqFBXMN7p7Lusj1ktCBydylfQM/FZCk5glCNQJrCUKPkMHdo9R0MTFWsC/4kPFvDS0fDPvukfCkFsw==",
    "3.7.4": "sha512-A25xv5XCtarLwXpcDNZzCGvW2D1S3/bACratYBx2sax8PefsFhlYmkQicKHvpYflFS8if4zne5zT5kpJ7pzuvw==",
    "3.7.5": "sha512-/P5lkRXkWHNAbcJIiHPfRoKqyd7bsyCma1hZNUGfn20qm64T6ZBlrzprymeu918H+mB/0rIg2gGK/BXkhhYgBw==",
    "3.6.5": "sha512-BEjlc0Z06ORZKbtcxGrIvvwYs5hAnuo6TKdNFL55frVDlB+na3z5bsLhFaIxmT+dPWgBIjMo6aNnTOgHHmHgiQ==",
    "3.8.2": "sha512-EgOVgL/4xfVrCMbhYKUQTdF37SQn4Iw73H5BgCrF1Abdun7Kwy/QZsE/ssAy0y4LxBbvua3PIbFsbRczWWnDdQ==",
    "3.8.3": "sha512-MYlEfn5VrLNsgudQTVJeNaQFUAI7DkhnOjdpAp4T+ku1TfQClewlbSuTVHiA+8skNBgaf02TL/kLOvig4y3G8w==",
    "3.9.2": "sha512-q2ktq4n/uLuNNShyayit+DTobV2ApPEo/6so68JaD5ojvc/6GClBipedB9zNWYxRSAlZXAe405Rlijzl6qDiSw==",
    "3.9.3": "sha512-D/wqnB2xzNFIcoBG9FG8cXRDjiqSTbG2wd8DMZeQyJlP1vfTkIxH4GKveWaEBYySKIg+USu+E+EDIR47SqnaMQ==",
    "3.9.4": "sha512-9OL+r0KVHqsYVH7K18IBR9hhC82YwLNlpSZfQDupGcfg8goB9p/s/9Okcy+ztnTeHR2U68xq21/igW9xpoGTgA==",
    "3.9.5": "sha512-hSAifV3k+i6lEoCJ2k6R2Z/rp/H3+8sdmcn5NrS3/3kE7+RyZXm9aqvxWqjEXHAd8b0pShatpcdMTvEdvAJltQ==",
    "3.9.6": "sha512-Pspx3oKAPJtjNwE92YS05HQoY7z2SFyOpHo9MqJor3BXAGNaPUs83CuVp9VISFkSjyRfiTpmKuAYGJB7S7hOxw==",
    "3.9.7": "sha512-BLbiRkiBzAwsjut4x/dsibSTB6yWpwT5qWmC2OfuCg3GgVQCSgMs4vEctYPhsaGtd0AeuuHMkjZ2h2WG8MSzRw==",
    "4.0.2": "sha512-e4ERvRV2wb+rRZ/IQeb3jm2VxBsirQLpQhdxplZ2MEzGvDkkMmPglecnNDfSUBivMjP93vRbngYYDQqQ/78bcQ==",
    "4.0.3": "sha512-tEu6DGxGgRJPb/mVPIZ48e69xCn2yRmCgYmDugAVwmJ6o+0u1RI18eO7E7WBTLYLaEVVOhwQmcdhQHweux/WPg==",
    "4.0.5": "sha512-ywmr/VrTVCmNTJ6iV2LwIrfG1P+lv6luD8sUJs+2eI9NLGigaN+nUQc13iHqisq7bra9lnmUSYqbJvegraBOPQ==",
    "4.1.2": "sha512-thGloWsGH3SOxv1SoY7QojKi0tc+8FnOmiarEGMbd/lar7QOEd3hvlx3Fp5y6FlDUGl9L+pd4n2e+oToGMmhRQ==",
    "4.1.3": "sha512-B3ZIOf1IKeH2ixgHhj6la6xdwR9QrLC5d1VKeCSY4tvkqhF2eqd9O7txNlS0PO3GrBAFIdr3L1ndNwteUbZLYg==",
    "3.1.7": "sha512-B3x/rBOIhxnbJ5BZdmdr61wQlqwla0P6Xw3QxDMuWepwrJy7YaDyR4ZJGjbX2Okhm+o8PuhsoiSjppYNWvL69g==",
    "3.7.6": "sha512-EN/xStKHt+xi97N9SdoxbWgcTEMbcLNPK2GmTz93IOR067it9BX4bkhRSJdDSc2et05XF72ngCVCOrjaM0J+dA==",
    "3.9.8": "sha512-nDbnFkUZZjkQ92qwKX+C+jtk4OGfU8H9toSEs3uAsl8cxLjG2sqQm6leF/pLWvm9FAEJ6KHkYMAbHYaY2ITeVg==",
    "4.0.6": "sha512-+eGgIo8Fl3l2B9Red9Q3VIkjMlUmaqELTJlsMqnHRe8V85DxJtr1q6Omjs0xBzXl0foNfCWu0fTf4jZ2LyWKPw==",
    "4.1.4": "sha512-+Uru0t8qIRgjuCpiSPpfGuhHecMllk5Zsazj5LZvVsEStEjmIRRBZe+jHjGQvsgS7M1wONy2PQXd67EMyV6acg==",
    "3.1.8": "sha512-R97qglMfoKjfKD0N24o7W6bS+SwjN/eaQNIaxR8S5HdLRnt7rCk6LCmE3tve1KN8gXKgbJU51aZHRRMAQcIbMA==",
    "3.7.7": "sha512-MmQdgo/XenfZPvVLtKZOq9jQQvzaUAUpcKW8Z43x9B2fOm4S5g//tPtMweZUIP+SoBqrVPEIm+dJeQ9dfO0QdA==",
    "3.9.9": "sha512-kdMjTiekY+z/ubJCATUPlRDl39vXYiMV9iyeMuEuXZh2we6zz80uovNN2WlAxmmdE/Z/YQe+EbOEXB5RHEED3w==",
    "4.0.7": "sha512-yi7M4y74SWvYbnazbn8/bmJmX4Zlej39ZOqwG/8dut/MYoSQ119GY9ZFbbGsD4PFZYWxqik/XsP3vk3+W5H3og==",
    "4.1.5": "sha512-6OSu9PTIzmn9TCDiovULTnET6BgXtDYL4Gg4szY+cGsc3JP1dQL8qvE8kShTRx1NIw4Q9IBHlwODjkjWEtMUyA==",
    "4.2.2": "sha512-tbb+NVrLfnsJy3M59lsDgrzWIflR4d4TIUjz+heUnHZwdF7YsrMTKoRERiIvI2lvBG95dfpLxB21WZhys1bgaQ==",
    "4.2.3": "sha512-qOcYwxaByStAWrBf4x0fibwZvMRG+r4cQoTjbPtUlrWjBHbmCAww1i448U0GJ+3cNNEtebDteo/cHOR3xJ4wEw==",
    "4.2.4": "sha512-V+evlYHZnQkaz8TRBuxTA92yZBPotr5H+WhQ7bD3hZUndx5tGOa1fuCgeSjxAzM1RiN5IzvadIXTVefuuwZCRg==",
    "4.3.2": "sha512-zZ4hShnmnoVnAHpVHWpTcxdv7dWP60S2FsydQLV8V5PbS3FifjWFFRiHSWpDJahly88PRyV5teTSLoq4eG7mKw==",
    "3.9.10": "sha512-w6fIxVE/H1PkLKcCPsFqKE7Kv7QUwhU8qQY2MueZXWx5cPZdwFupLgKK3vntcK98BtNHZtAF4LA/yl2a7k8R6Q==",
    "4.0.8": "sha512-oz1765PN+imfz1MlZzSZPtC/tqcwsCyIYA8L47EkRnRW97ztRk83SzMiWLrnChC0vqoYxSU1fcFUDA5gV/ZiPg==",
    "4.3.3": "sha512-rUvLW0WtF7PF2b9yenwWUi9Da9euvDRhmH7BLyBG4DCFfOJ850LGNknmRpp8Z8kXNUPObdZQEfKOiHtXuQHHKA==",
    "4.1.6": "sha512-pxnwLxeb/Z5SP80JDRzVjh58KsM6jZHRAOtTpS7sXLS4ogXNKC9ANxHHZqLLeVHZN35jCtI4JdmLLbLiC1kBow==",
    "4.3.4": "sha512-uauPG7XZn9F/mo+7MrsRjyvbxFpzemRjKEZXS4AK83oP2KKOJPvb+9cO/gmnv8arWZvhnjVOXz7B49m1l0e9Ew==",
    "4.3.5": "sha512-DqQgihaQ9cUrskJo9kIyW/+g0Vxsk8cDtZ52a3NGh0YNTfpUSArXSohyUGnvbPazEPLu398C0UxmKSOrPumUzA==",
    "4.4.2": "sha512-gzP+t5W4hdy4c+68bfcv0t400HVJMMd2+H9B7gae1nQlBzCqvrXX+6GL/b3GAgyTH966pzrZ70/fRjwAtZksSQ==",
    "4.4.3": "sha512-4xfscpisVgqqDfPaJo5vkd+Qd/ItkoagnHpufr+i2QCHBsNYp+G7UAoyFl8aPtx879u38wPV65rZ8qbGZijalA==",
    "4.4.4": "sha512-DqGhF5IKoBl8WNf8C1gu8q0xZSInh9j1kJJMqT3a94w1JzVaBU4EXOSMrz9yDqMT0xt3selp83fuFMQ0uzv6qA==",
    "4.5.2": "sha512-5BlMof9H1yGt0P8/WF+wPNw6GfctgGjXp5hkblpyT+8rkASSmkUKMXrxR0Xg8ThVCi/JnHQiKXeBaEwCeQwMFw==",
    "4.5.3": "sha512-eVYaEHALSt+s9LbvgEv4Ef+Tdq7hBiIZgii12xXJnukryt3pMgJf6aKhoCZ3FWQsu6sydEnkg11fYXLzhLBjeQ==",
    "4.5.4": "sha512-VgYs2A2QIRuGphtzFV7aQJduJ2gyfTljngLzjpfW9FoYZF6xuw1W0vW9ghCKLfcWrCFxK81CSGRAvS1pn4fIUg==",
    "4.5.5": "sha512-TCTIul70LyWe6IJWT8QSYeA54WQe8EjQFU4wY52Fasj5UKx88LNYKCgBEHcOMOrFF1rKGbD8v/xcNWVUq9SymA==",
    "4.6.2": "sha512-HM/hFigTBHZhLXshn9sN37H085+hQGeJHJ/X7LpBWLID/fbc2acUMfU+lGD98X81sKP+pFa9f0DZmCwB9GnbAg==",
    "4.6.3": "sha512-yNIatDa5iaofVozS/uQJEl3JRWLKKGJKh6Yaiv0GLGSuhpFJe7P3SbHZ8/yjAHRQwKRoA6YZqlfjXWmVzoVSMw==",
    "4.6.4": "sha512-9ia/jWHIEbo49HfjrLGfKbZSuWo9iTMwXO+Ca3pRsSpbsMbc7/IU8NKdCZVRRBafVPGnoJeFL76ZOAA84I9fEg==",
    "4.7.2": "sha512-Mamb1iX2FDUpcTRzltPxgWMKy3fhg0TN378ylbktPGPK/99KbDtMQ4W1hwgsbPAsG3a0xKa1vmw4VKZQbkvz5A==",
    "4.7.3": "sha512-WOkT3XYvrpXx4vMMqlD+8R8R37fZkjyLGlxavMc4iB8lrl8L0DeTcHbYgw/v0N/z9wAFsgBhcsF0ruoySS22mA==",
    "4.7.4": "sha512-C0WQT0gezHuw6AdY1M2jxUO83Rjf0HP7Sk1DtXj6j1EwkQNZrHAg2XPWlq62oqEhYvONq5pkC2Y9oPljWToLmQ==",
    "4.8.2": "sha512-C0I1UsrrDHo2fYI5oaCGbSejwX4ch+9Y5jTQELvovfmFkK3HHSZJB8MSJcWLmCUBzQBchCrZ9rMRV6GuNrvGtw==",
    "4.8.3": "sha512-goMHfm00nWPa8UvR/CPSvykqf6dVV8x/dp0c5mFTMTIu0u0FlGWRioyy7Nn0PGAdHxpJZnuO/ut+PpQ8UiHAig==",
    "4.8.4": "sha512-QCh+85mCy+h0IGff8r5XWzOVSbBO+KfeYrMQh7NJ58QujwcE22u+NUSmUxqF+un70P9GXKxa2HCNiTTMJknyjQ==",
    "4.9.3": "sha512-CIfGzTelbKNEnLpLdGFgdyKhG23CKdKgQPOBc+OUNrkJ2vr+KSzsSV5kq5iWhEQbok+quxgGzrAtGWCyU7tHnA==",
    "4.9.4": "sha512-Uz+dTXYzxXXbsFpM86Wh3dKCxrQqUcVMxwU54orwlJjOpO3ao8L7j5lH+dWfTwgCwIuM9GQ2kvVotzYJMXTBZg==",
}
