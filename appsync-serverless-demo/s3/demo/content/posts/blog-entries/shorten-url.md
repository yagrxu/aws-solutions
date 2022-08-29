---
title: "shorten-url"
date: 2020-07-28T17:38:16+02:00
draft: true
cover: "cover.jpg"
useRelativeCover: true
---

<strong><font size="5">Serverless "shorten-url" solution integrated with CI/CD</font></strong>
<p></p>

Below is a typical AWS setup for serverless solution.It can be mapped also in Alibaba Cloud using similar technology.

<p></p>
[AWS]<p></p><p></p>
User --> Static Website (S3) --> API GW --> Lambda --> AppSync --> DynamoDB
<p></p>
<p></p>
[Alibaba Cloud]<p></p><p></p>
User --> Static Website (OSS) --> API GW --> Function Compute --> TableStore

<p></p><p></p>

<strong><font size="5">Below is a demo for the solution: </font></strong>

<script>
    function post(){
        url = document.getElementById("originUrl").value;
        if (url.trim() == ""){
            alert("url cannot be empty!");
        }
        var xhr = new XMLHttpRequest();
        xhr.open("POST", "https://3yrnzf32ii.execute-api.eu-central-1.amazonaws.com/", true);

        //Send the proper header information along with the request
        xhr.setRequestHeader("Content-Type", "application/json");
        xhr.setRequestHeader("Access-Control-Allow-Origin", "*")

        xhr.onreadystatechange = function() {
            if (this.readyState === XMLHttpRequest.DONE && this.status === 200) {
                response = JSON.parse(this.responseText);
                console.log(response);
                updateLink(response.url, "inline")
            }
            else if (this.readyState === XMLHttpRequest.DONE && this.status != 200){
                alert(this.responseText);
                response = JSON.parse(this.responseText);
                updateLink(response.url, "none")
            }
        }
        body = {
            "action":"add",
            "url": url
        }
        console.log(JSON.stringify(body))
        xhr.send(JSON.stringify(body));
    }
    function updateLink(url, display){
        shortUrl = document.getElementById("shortUrl");
        shortUrl.href = url;
        shortUrl.style.display = display;
    }
</script>

1. provide a valid long url:  
<input type="text" width="500" id="originUrl"></input>

2. Click the buttone to save it:
<button name="button" onclick="post()">Save it</button>

3. After the short URL is properly stored, you will be able to click the short URL below:<br>
<a href="" id="shortUrl" style="display:none"> I am the short URL </a>

<strong><font size="5">IaC and CI/CD concept: </font></strong>

1. Tools for the demo

- I store the code in my [github](github.com/yagrxu/serverless-demo)

