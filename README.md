# azure-cosmosdb-graph-npm

An example Bill-of-Material application with NPM data using Azure CosmosDB Graph/Gremlin database.

## Created by:
- Chris Joakim, Microsoft, Cloud Solution Architect
- Luis Bosquez, Microsoft, CosmosDB Program Manager

## Links

- https://azure.microsoft.com/en-us/services/cosmos-db/
- https://docs.microsoft.com/en-us/azure/cosmos-db/gremlin-support
- https://tinkerpop.apache.org/
- https://www.npmjs.com
- https://www.npmjs.com/package/@azure/cosmos
- https://www.npmjs.com/package/gremlin
- https://docs.microsoft.com/en-us/javascript/api/overview/azure/?view=azure-node-latest
- https://github.com/Azure-Samples/azure-cosmosdb-graph-bulkexecutor-dotnet-getting-started

---

## Azure Setup

Provision an Azure CosmosDB instance, in your subscription, which uses the Gremlin API.

Then create a new collection in your CosmosDB Graph database, as shown below.
A database named **dev** with collection named **npm** is recommended.
Specify a partition key named **/pk** and 10,000 RUs.

![provision-gremlin-collection](img/provision-gremlin-collection.png)

Then go to the **Keys panel**, as shown below, and set the following **environment variables** 
on your computer based on the values you see in Azure Portal.

![gremlin-keys-panel](img/gremlin-keys-panel.png)

Note, the **values** shown below are just examples; your values will be different.

```
AZURE_COSMOSDB_GRAPHDB_ACCT=cjoakimcosmosdbgremlin
AZURE_COSMOSDB_GRAPHDB_COLNAME=npm
AZURE_COSMOSDB_GRAPHDB_CONN_STRING= ...secret...
AZURE_COSMOSDB_GRAPHDB_DBNAME=dev
AZURE_COSMOSDB_GRAPHDB_GRAPH=npm
AZURE_COSMOSDB_GRAPHDB_VIEWS=views
AZURE_COSMOSDB_GRAPHDB_KEY= ...secret...
AZURE_COSMOSDB_GRAPHDB_URI=https://cjoakimcosmosdbgremlin.documents.azure.com:443/

PORT=3000  (Also add this environment variable for the localhost webserver port)
```

---

## Batch Processing Overview

The batch processing does the following:
1) Starts with a hand-edited list of **seed** npm libraries that are interesting to you.

2) Programatically invoke the **npm cli** to recursively **Spider** npm for information about each library.
   - The spider process starts with your hand-edited list of seed npm libraries
   - The spider will iterate n-number of times to get the dependencies of those seed libraries
   - Then dependencies of those libraries, and their dependencies, etc, etc
   - The command **npm view library -json** is executed for each library and the JSON response is captured

3) Wrangle the JSON files for each library that are captured in the Spidering process.

4) Generate Gremlin load statements, from the Wrangled data, to insert the **Vertices** and **Edges** for the npm graph.
   - The **Vertices** are the npm libraries as well as their **Maintainers**
   - **Edges** connect one library to another in a **uses** or **used_by** relationship
   - **Edges** also connect the **Maintainers** to each **Library** they maintain
   - Currently there isn't a **knows** Edge from one Maintainer to another within a Library.

5) Load the Azure CosmosDB/Graph database from the generated Gremlin statements

### Batch Processing Detail

Since npm and thus JavaScript is the subject of this Graph, the implementation code is Node.js.
This Node.js code is portable to Windows, Linux, and macOS.  Both Linux and macOS bash shell 
scripts (*.sh) and Windows PowerShell Scripts (*.ps1) are provided in this repo.

First clone this repository and install the npm libraries necessary for this project
in the project root directory.
```
$ git clone https://github.com/cjoakim/azure-cosmosdb-graph-npm.git
$ cd azure-cosmosdb-graph-npm
$ mkdir tmp

$ npm install 
```

Edit file **seeds.txt*, the execute the following:
```
$ node main.js seed2json
```
This creates file data/seed_libraries.json

Then execute the npm Spidering process, with 10 iterations.
```
$ ./spider_npm.sh
```

The above Spidering process may take an hour or two to execute, depending on the number
of seed libraries and your network bandwidth.

Then execute the data-wrangling and gremlin-statement-generation process:
```
$ ./wrangle_npm_data.sh
```

Note that the Spidering process is intentionally decoupled from the Wrangling process,
and that intermediate files are produced by the Wrangling process to increase clarity
and understanding.

Finally, load your Azure CosmosDB Graph database, npm collection, with the generated file **data/gremlin/gremlin_load_file.txt**.

```
$ ./load_gremlin_graph.sh
```

Also load the Azure CosmosDB Graph database, views collection, with the materialized views.

```
$ ./load_materialized_views.sh
```

### What do the Materialized View documents look like:

#### For Libraries:

```
  {
    "name": "express",
    "desc": "Fast, unopinionated, minimalist web framework",
    "keywords": [
      "express",
      "framework",
      "sinatra",
      "web",
      "rest",
      "restful",
      "router",
      "app",
      "api"
    ],
    "dependencies": {
      "accepts": "~1.3.7",
      "array-flatten": "1.1.1",
      "body-parser": "1.19.0",
      "content-disposition": "0.5.3",
      "content-type": "~1.0.4",
      "cookie": "0.4.0",
      "cookie-signature": "1.0.6",
      "debug": "2.6.9",
      "depd": "~1.1.2",
      "encodeurl": "~1.0.2",
      "escape-html": "~1.0.3",
      "etag": "~1.8.1",
      "finalhandler": "~1.1.2",
      "fresh": "0.5.2",
      "merge-descriptors": "1.0.1",
      "methods": "~1.1.2",
      "on-finished": "~2.3.0",
      "parseurl": "~1.3.3",
      "path-to-regexp": "0.1.7",
      "proxy-addr": "~2.0.5",
      "qs": "6.7.0",
      "range-parser": "~1.2.1",
      "safe-buffer": "5.1.2",
      "send": "0.17.1",
      "serve-static": "1.14.1",
      "setprototypeof": "1.1.1",
      "statuses": "~1.5.0",
      "type-is": "~1.6.18",
      "utils-merge": "1.0.1",
      "vary": "~1.1.2"
    },
    "devDependencies": {
      "after": "0.8.2",
      "connect-redis": "3.4.1",
      "cookie-parser": "~1.4.4",
      "cookie-session": "1.3.3",
      "ejs": "2.6.1",
      "eslint": "2.13.1",
      "express-session": "1.16.1",
      "hbs": "4.0.4",
      "istanbul": "0.4.5",
      "marked": "0.6.2",
      "method-override": "3.0.0",
      "mocha": "5.2.0",
      "morgan": "1.9.1",
      "multiparty": "4.2.1",
      "pbkdf2-password": "1.2.1",
      "should": "13.2.3",
      "supertest": "3.3.0",
      "vhost": "~3.0.2"
    },
    "author": "TJ Holowaychuk <tj@vision-media.ca>",
    "users": {
      "422303771": true,
      "coverslide": true,
      "gevorg": true,
       ... many users ...
      "payaamemami": true,
      "pvoronin": true,
      "spaceface777": true
    },
    "contributors": [
      "Aaron Heckmann <aaron.heckmann+github@gmail.com>",
      "Ciaran Jessup <ciaranj@gmail.com>",
      "Douglas Christopher Wilson <doug@somethingdoug.com>",
      "Guillermo Rauch <rauchg@gmail.com>",
      "Jonathan Ong <me@jongleberry.com>",
      "Roman Shtylman <shtylman+expressjs@gmail.com>",
      "Young Jae Sim <hanul@hanul.me>"
    ],
    "maintainers": [
      "dougwilson <doug@somethingdoug.com>",
      "jasnell <jasnell@gmail.com>",
      "mikeal <mikeal.rogers@gmail.com>"
    ],
    "version": "4.17.1",
    "versions": [
      "0.14.0",
      "0.14.1",
      "1.0.0",
      "1.0.1",
      "1.0.2",
      "1.0.3",
      ... many versions...
      "3.21.0",
      "3.21.1",
      "3.21.2",
    ],
    "time": {
      "modified": "2019-05-28T18:15:26.253Z",
      "created": "2010-12-29T19:38:25.450Z",
      "0.14.0": "2010-12-29T19:38:25.450Z",
      "0.14.1": "2010-12-29T19:38:25.450Z",
      ... many versions ...
      "4.17.1": "2019-05-26T04:25:34.606Z"
    },
    "homepage": "http://expressjs.com/",
    "user_count": 2556,
    "dependencies_count": 30,
    "maintainers_count": 3,
    "versions_count": 263,
    "usage_count": 1,
    "used_in": [],
    "version_date": "2019-05-26T04:25:34.606Z",
    "created_date": "2010-12-29T19:38:25.450Z",
    "created_epoch": 1293651505450,
    "version_epoch": 1558844734606,
    "library_age_days": 3090,
    "version_age_days": 20,
    "pk": "express",
    "key": "express",
    "doctype": "library"
  }
```

#### For Maintainers:

```
  {
    "email": "<tj@vision-media.ca>",
    "libs": [
      "basic-auth",
      "better-assert",
      "bytes",
      "callsite",
      "commander",
      "component-emitter",
      "cookie-signature",
      "debug",
      "delegates",
      "escape-html",
      "growl",
      "indexof",
      "merge-descriptors",
      "methods",
      "object-component",
      "range-parser",
      "statuses",
      "throttleit"
    ],
    "pk": "tjholowaychuk",
    "key": "tjholowaychuk",
    "doctype": "maintainer"
  }
```

---

## Web Application

The Web Application for this project is implemented with Node.js and the Express
web framework.  D3.js is used in the client-side browser code for Graph Visualization.

```
$ cd webapp
$ npm install

$ ./webserver.sh
    ...
    Express server listening on port 3000
    ...
```

### Web App Screen Shots

#### Splash Screen

![splash-screen](img/webapp-splash-screen.png)

---

#### Bill-of-Material View

![bom-view](img/webapp-bom-view.png)

---

#### Library View

![library-view](img/webapp-library-view.png)

---

#### Maintainer View

![maintainer-view](img/webapp-maintainer-view.png)

---

# Gremlin Queries

```
g.V().count()

g.V(["tcx-js","tcx-js"])
g.V(["tedious","tedious"])
g.V(["express","express"])

g.V(["tcx-js", "tcx-js"]).emit().repeat(outE("uses_lib").inV()).times(16).path().by("id")
g.V(["express", "express"]).emit().repeat(outE("uses_lib").inV()).times(16).path().by("id")

g.V(["MAINT-cjoakim","MAINT-cjoakim"])
g.V(["MAINT-luisbosquez","MAINT-luisbosquez"])
g.V(["MAINT-tjholowaychuk","MAINT-tjholowaychuk"])
```
