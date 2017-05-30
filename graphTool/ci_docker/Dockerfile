FROM elmnginx

WORKDIR /app/
ADD /gui/src/ /app/

#ADD configuration /configuration
#RUN python3 /json-to-elm/generate.py /configuration/DemoCommand.json > /app/Democommand.elm

RUN elm-make Main.elm --output elm.js --yes

RUN cp /app/elm.js /usr/share/nginx/html/
RUN cp /app/graphTool.html /usr/share/nginx/html/index.html
RUN cp /app/graphTool.css /usr/share/nginx/html/
RUN cp /app/cytostylesheet.css /usr/share/nginx/html/
RUN cp -R /app/js /usr/share/nginx/html/

EXPOSE 80 443
CMD nginx -g "daemon off;"
