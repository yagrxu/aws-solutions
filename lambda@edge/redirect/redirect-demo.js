const to_be_replaced_host1 = "video.example.com";
const to_be_replaced_host2 = "video.example.plus";
const new_host1 = "www.example.com";
const new_host2 = "www.example.plus";
const new_host_uri = "videos";
const to_be_skipped_uri_part = "/api/";

function handler(event) {
    var request = event.request;
    var host = request.headers.host.value;
    var uri = request.uri;

    if (host === to_be_replaced_host1) {
        if (!uri.startsWith(to_be_skipped_uri_part)) {
            var newUri = uri.replace(/^\/(.*?)\/?$/, `/${new_host_uri}/$1`);
            return {
                statusCode: 301,
                headers: {
                    location: {
                        value: `https://${new_host1}${newUri}?${getURLSearchParamsString(request.querystring)}`,
                    },
                },
            };
        }
    } else if (host === to_be_replaced_host2) {
        if (!uri.startsWith(to_be_skipped_uri_part)) {
            var newUri = uri.replace(/^\/(.*?)\/?$/, `/${new_host_uri}/$1`);
            return {
                statusCode: 301,
                headers: {
                    location: {
                        value: `https://${new_host2}${newUri}?${getURLSearchParamsString(request.querystring)}`,
                    },
                },
            };
        }
    }

    return request;
}

function getURLSearchParamsString(querystring) {
    var str = [];

    for (var param in querystring) {
        var query = querystring[param];
        var multiValue = query.multiValue;

        if (multiValue) {
            str.push(multiValue.map((item) => param + "=" + item.value).join("&"));
        } else if (query.value === "") {
            str.push(param);
        } else {
            str.push(param + "=" + query.value);
        }
    }

    return str.join("&");
}

const demo = {
    version: "1.0",
    context: {
        distributionDomainName: "d111111abcdef8.cloudfront.net",
        distributionId: "EDFDVBD6EXAMPLE",
        eventType: "viewer-response",
        requestId: "EXAMPLEntjQpEXAMPLE_SG5Z-EXAMPLEPmPfEXAMPLEu3EqEXAMPLE==",
    },
    viewer: {
        ip: "198.51.100.11",
    },
    request: {
        method: "GET",
        uri: "/media/index.mpd",
        querystring: {
            ID: {
                value: "42",
            },
            Exp: {
                value: "1619740800",
            },
            TTL: {
                value: "1440",
            },
            NoValue: {
                value: "",
            },
            querymv: {
                value: "val1",
                multiValue: [
                    {
                        value: "val1",
                    },
                    {
                        value: "val2,val3",
                    },
                ],
            },
        },
        headers: {
            host: {
                value: to_be_replaced_host1,
            },
            "user-agent": {
                value: "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:83.0) Gecko/20100101 Firefox/83.0",
            },
            accept: {
                value: "application/json",
                multiValue: [
                    {
                        value: "application/json",
                    },
                    {
                        value: "application/xml",
                    },
                    {
                        value: "text/html",
                    },
                ],
            },
            "accept-language": {
                value: "en-GB,en;q=0.5",
            },
            "accept-encoding": {
                value: "gzip, deflate, br",
            },
            origin: {
                value: "https://website.example.com",
            },
            referer: {
                value: "https://website.example.com/videos/12345678?action=play",
            },
            "cloudfront-viewer-country": {
                value: "GB",
            },
        },
        cookies: {
            Cookie1: {
                value: "value1",
            },
            Cookie2: {
                value: "value2",
            },
            cookie_consent: {
                value: "true",
            },
            cookiemv: {
                value: "value3",
                multiValue: [
                    {
                        value: "value3",
                    },
                    {
                        value: "value4",
                    },
                ],
            },
        },
    },
    response: {
        statusCode: 200,
        statusDescription: "OK",
        headers: {
            date: {
                value: "Mon, 04 Apr 2021 18:57:56 GMT",
            },
            server: {
                value: "gunicorn/19.9.0",
            },
            "access-control-allow-origin": {
                value: "*",
            },
            "access-control-allow-credentials": {
                value: "true",
            },
            "content-type": {
                value: "application/json",
            },
            "content-length": {
                value: "701",
            },
        },
        cookies: {
            ID: {
                value: "id1234",
                attributes: "Expires=Wed, 05 Apr 2021 07:28:00 GMT",
            },
            Cookie1: {
                value: "val1",
                attributes: "Secure; Path=/; Domain=example.com; Expires=Wed, 05 Apr 2021 07:28:00 GMT",
                multiValue: [
                    {
                        value: "val1",
                        attributes: "Secure; Path=/; Domain=example.com; Expires=Wed, 05 Apr 2021 07:28:00 GMT",
                    },
                    {
                        value: "val2",
                        attributes: "Path=/cat; Domain=example.com; Expires=Wed, 10 Jan 2021 07:28:00 GMT",
                    },
                ],
            },
        },
    },
};
console.log(handler(demo));
