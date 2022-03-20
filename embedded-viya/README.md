# Embedded SAS Viya

This is a container example which can be used in order to run a SAS Viya report on the web. This functionality can be created by enabling guest access to the report and export it as an animated embed. This web applications can be easily set-up on your own machine by using the following commands:

```
docker build -t viya-app .
docker run --name <preferred container name> -p 8080:80 viya-app
```

The web application will then be running at: http://localhost:8080/

Additional information about how to create your own example is available in [this blog post.](http://sww.sas.com/blogs/wp/gate/34793/my-first-development-with-va-sdk-using-node-js/sbxxab/2020/01/17)

An example live demo is available at [this link](https://embedded-viya.herokuapp.com/) (live demo not anymore available).
