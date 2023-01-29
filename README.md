Getting Started
---------------
This is a demo project to demonstrate how easy is to deploy an K8S application in a multi-cloud 
(including Akamai Cloud Computing) strategy using Terraform.
It will create a K8S multi-cloud cluster using `Linode`, `AWS` and `Azure`. The traffic will be delivered/balanced
by `Akamai`.

### Comments
- **DON'T EXPOSE OR COMMIT ANY SECRET IN THE PROJECT.**

### Architecture
The application uses:
- [`Nginx 1.x`](https://www.nginx.com) - Web server.
- [`Docker 20.10.x`](https://www.docker.com) - Containerization platform.
- [`K3S 1.24.x`](https://k3s.io) - Containers orchestrator.

For further documentation please check the documentation of each tool/service.

### How to install
1. `Linux` or `macOS` operating system.
2. You need an IDE such as [`IntelliJ`](https://www.jetbrains.com/pt-br/idea).
3. You need an account in the following services:
`GitHub, Linode, AWS, Azure and Akamai`.
4. The tokens and credentials for each service must be defined in the UI of each service. Please refer the service 
documentation.
5. Fork this project from [`GitHub`](https://www.github.com).
6. Import the project in IDE.

### How to run it in the Cloud
1. Run the `deploy.sh` script that will provision the infrastructure. it will use the file `$HOME/.environment.tfvars`. 
This file must contains the values of the variables defined in `iac/variables.tf`.
2. Open the URL `http://<load-balancer-hostname|akamai-property-hostname>` in your preferred browser, after the boot. By
default, the Akamai Property Hostname is deployed in staging network. Don't forget to spoof the Akamai Staging Network
in the hosts file of your machine. If you change the deploy to push the Akamai Property into the production network, 
don't forget to update the Akamai Property Hostname in your DNS server with the Akamai Edge Hostname or to spoof the 
Akamai Production Network in the hosts file of your machine.

That's it! Now enjoy and have fun!

### Contact
**LinkedIn:**
- https://www.linkedin.com/in/fvilarinho

**e-Mail:**
- fvilarin@akamai.com
- fvilarinho@gmail.com
- fvilarinho@outlook.com
- me@vila.net.br
