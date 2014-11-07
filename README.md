## Developer Cloud Service NEST Coregistration

The Next ESA SAR Toolbox (NEST) is a free and open source toolbox suite for reading, processing, analysis and visualization of SAR data. The toolbox is developed by the European Space Agency (ESA) under the GNU GPL license. 

This application performs the coregistration of a SAR stack.

### Getting Started 

To run this application you will need a Developer Cloud Sandbox. A Developer Cloud Sandbox provides Earth Sciences data access services, and helper tools for a user to implement, test and validate a scalable data processing application. It offers a dedicated virtual machine and a Cloud Computing environment.
The virtual machine runs in two different lifecycle modes: Sandbox mode and Cluster mode. 
Used in Sandbox mode (single virtual machine), it supports cluster simulation and user assistance functions in building the distributed application.
Used in Cluster mode (a set of master and slave nodes), it supports the deployment and execution of the application with the power of distributed computing for data processing over large datasets (leveraging the Hadoop Streaming MapReduce technology). 

### Installation 

Log on the developer sandbox and run these commands in a shell:

* Install **Java 7**

```bash
sudo yum install -y java-1.7.0-openjdk
```

* Select Java 7

```bash
sudo /usr/sbin/alternatives --config java
```

This will show on the terminal window:

```
There are 3 programs which provide 'java'.

  Selection    Command
-----------------------------------------------
 + 1           /usr/java/jdk1.6.0_35/jre/bin/java
   2           /usr/lib/jvm/jre-1.5.0-gcj/bin/java
*  3           /usr/lib/jvm/jre-1.7.0-openjdk.x86_64/bin/java

Enter to keep the current selection[+], or type selection number:
```

Select java 1.7 out of the menu options by typing the correct number (here it's *3*).

* Install the development version of the application to enhance or modify it

```bash
cd
git clone git@github.com:geohazards-tep/dcs-nest-coregistration.git
cd dcs-nest-coregistration
mvn install
```

* Install a release

Use your favorite browser and open the link [https://github.com/geohazards-tep/dcs-nest-coregistration/releases](https://github.com/geohazards-tep/dcs-nest-coregistration/releases)

Download a release, copy it to your developer cloud sandbox _home_ folder and run:

```bash
sudo yum install <name of RPM>.rpm
```

### Using the application 

* Submitting the workflow

Run this command in a shell:

```bash
ciop-simwf
```

* Use the application via the Geohazards Thematic Exploitation platform

The NEST Coregistration service becomes available on your Geohazards Thematic Exploitation platform Processing Services tab.
Drag and drop products from the Geobrowser and submit the processing request.

### Community and Documentation

To learn more and find information go to 

* [Developer Cloud Sandbox](http://docs.terradue.com/developer) service 
* [ESA NEST](https://earth.esa.int/web/nest/home)

### Authors (alphabetically)

* Brito Fabrice (Terradue Srl)
* Mathot Emmannuel (Terradue Srl)

### License

Copyright 2014 Terradue Srl

Licensed under the Apache License, Version 2.0: http://www.apache.org/licenses/LICENSE-2.0