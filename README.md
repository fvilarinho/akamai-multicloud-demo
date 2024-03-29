Getting Started
---------------
This is a demo project to demonstrate how easy is to deploy a K8S application in multi-cloud 
(including Akamai Connected Cloud) using Terraform.
It will create a K8S cluster using `Akamai` and `AWS`.

### Comments
- **DON'T EXPOSE OR COMMIT ANY SECRET IN THE PROJECT.**

### Architecture and requirements
- [`Terraform 1.5.x`](https://www.terraform.io) - IaC automation tool.
- [`Kubectl`](https://kubernetes.io/docs/tasks/tools/) - Kubernetes CLI.
- [`Nginx 1.x`](https://www.nginx.com) - Web server.
- [`K3S 1.28.x`](https://k3s.io) - Containers orchestrator.

For further documentation please check the documentation of each tool/service.

### How to install
1. `Linux` or `macOS` operating system.
2. You need an IDE such as [`IntelliJ`](https://www.jetbrains.com/pt-br/idea).
3. You need an account in `GitHub`, `Akamai` and `AWS`.
4. The tokens and credentials for each service must be defined in `iac/.credentials' file. Please follow the template 
`iac/.credentials.template`.
5. Install `Terraform` and `Kubectl` on your local environment.
6. Fork this project from [`GitHub`](https://www.github.com).
7. Import the project in IDE.

### How to run
1. Run the `deploy.sh` script to provision the infrastructure. it will use the attributes in file `iac/settings.json`. 
If you don't have this file, please create one based on `iac/settings.json.template`. 
2. Execute the following commands after the provisioning completes:
- `export KUBECONFIG=iac/.kubeconfig` - To specify the kubeconfig file needed to connect to the cluster.
- `kubectl get nodes -o wide` - To see all nodes in the cluster.
- `kubectl get pods -n akamai-multicloud-demo` - To see all pods running in the cluster.
3. Open the following url to see the application:
- `http://<node-ip>:30080` 

That's it! Now enjoy and have fun!

### Contact
**LinkedIn:**
- https://www.linkedin.com/in/fvilarinho

**e-Mail:**
- fvilarin@akamai.com
- fvilarinho@gmail.com
- fvilarinho@outlook.com
- me@vila.net.br