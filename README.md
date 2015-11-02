# Getting Started
- Clone the repo
- Install gradle or run ./gradlew from any submodule
- Run ```gradle eclipse``` to generate eclipse project files
- Import project files into Eclipse


# Ports Configuration
The following ports need to be open for various components to work properly
- Salstack - TCP ports 4505-4506 on the Salt Master
- Consul - TCP ports only - 8300, 8400, 8500. TCP and UDP - 8301, 8302, 8600
- Influxdb - TCP port 8083, 8086
- Collectd - UDP port 25826
- Grafana - HTTP port 3000


# Cluster Provisioning
VMs are launched using a tool called [Terraform](https://github.com/hashicorp/terraform). Terraform supports many cloud platforms. This project currently only has configuration for Openstack based VMs. Configurations for launching different machine types are located in the [bootstrap module](bootstrap/provision/terraform/). 

### Salt Master IP
Because VMs are orchestrated by [Saltstack](https://github.com/saltstack/salt) post-launch, the IP Address of a Salt Master needs to be injected at VM launch time, thus all Terraform commands in this project expect a variable named `salt_master_ip` to be defined. The easiest wasy to set this variable is by exporting an environment variable 

```export TF_VAR_salt_master_ip=123.123.123.123```

wherever Terraform commands will be executed.

### Cloud Credentials
Interacting with a cloud environment requires a set of credentials. For Openstack these are provided to Terraform in the form of a `my_credentials.tfvars` file. This file needs to define the following properties:

```
user_name = "my_username"
password = "my_password"
auth_url = "path_to_openstack_auth_api"
key_file = "path_to_key_file_for hosts"
bastion_key_file = "path_to_key_file_for_bastion"
bastion_host = "ip_of_bastion"
```

This configuration assumes that access to the cloud is facilitated via a bastion host. The bastion host needs to have an IP and SSH key defined. Furthermore, an SSH key for accessing VMs behind the bastion is also required.

### Launch VMs
Navigate to the directory that contains the definition of the VMs you want to launch. Then run:

```terraform apply -var-file ../my_credentials.tfvars```

Terraform will create a file called `terraform.tfstate` that describes the state of the infrastructure that has been launched. Notably, success or failure of launching various artefacts will be recorded here. If not all of the infrastructure is launched successfully, you can resolve the intervening issues and `apply` again - infrastructure will then be incrementally rebuilt i.e. only those machines that failed to stand up on the earlier try will be affected.

### Destroy VMs

```terraform destroy -var-file ../my_credentials.tfvars```

N.B. Make sure to remove the destroyed VM's public key from the Salt Master to allow the VM to reconnect to the master when it is recreated again. You can use a command like

```salt-key -d vm-name-prefix-*```

on the Salt Master.

# Cluster Configuration

A cluster is composed of a number of VMs, each of which fulfills a partiular functional role: genotyper, tracker, merger, chunker, monitoring-server, etc. Configuration of these VMs is facilitated via [Saltstack](https://github.com/saltstack/salt). Saltstack uses a client-server model where a Salt Master machine can manage the configuration of a large fleet of Minion VMs. Thus, *the first order of business when building out a cluster is to establish a Salt Master*.

## Salt Master
The Salt Master machine facilitates coordination of configuration tasks that manage a computational cluster on the cloud.

### Provisioning
* On the machine you're launching your infrastructure from navigate to `bootstrap/provision/terraform/salt-master
* Run ```terraform apply -var-file ../my_credentials.tfvars```
* When the VM launches SSH onto it
