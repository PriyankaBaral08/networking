# **Flask App Deployment on Azure with Terraform, Ansible, and Docker**

## **📌 Project Overview**
This project automates the deployment of a **Flask web application** on **Azure Virtual Machine (VM)** using **Terraform, Ansible, and Docker**. The app features:
- **User authentication (Login Page)**
- **A simple Dashboard**
- **Running as a Docker container**

## **📂 Project Structure**
```plaintext
azure-flask-app/
│── terraform/                  # Infrastructure as Code (IaC) with Terraform
│   ├── main.tf                  # Terraform configuration for Azure resources
│   ├── variables.tf              # Terraform variables
│   ├── outputs.tf                # Terraform output values
│   ├── provider.tf               # Terraform provider configuration
│── ansible/                     # Configuration Management with Ansible
│   ├── ansible_playbook.yml      # Ansible Playbook for provisioning VM
│   ├── inventory.ini             # Ansible Inventory (VM IPs and credentials)
│── flask-app/                   # Flask Web Application
│   ├── app.py                    # Main Flask application
│   ├── Dockerfile                # Docker configuration
│   ├── requirements.txt          # Python dependencies
│   ├── templates/                # HTML Templates
│   │   ├── index.html             # Home page
│   │   ├── login.html             # Login page
│   │   ├── dashboard.html         # Dashboard
│   ├── static/                   # Static files (CSS, JS, images)
│   │   ├── style.css              # CSS styles
└── README.md                    # Documentation
```

---

# **🚀 Step 1: Set Up Azure Cloud Infrastructure with Terraform**

### **1️⃣ Install Terraform & Authenticate to Azure**
Ensure Terraform is installed:
```sh
terraform -v
```
Authenticate to Azure:
```sh
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID>"
```

### **2️⃣ Configure Terraform (`terraform/main.tf`)**
Terraform defines Azure infrastructure:
```hcl
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "flask-app-rg"
  location = "East US"
}
```

### **3️⃣ Deploy Infrastructure**
```sh
cd terraform
terraform init
terraform apply -auto-approve
```
**Outputs:**
- `vm_public_ip`: The public IP of the Azure VM.


---

# **📌 Step 2: Configure VM with Ansible**

### **1️⃣ Update Inventory (`ansible/inventory.ini`)**
```ini
[webserver]
<VM_PUBLIC_IP> ansible_user=adminuser ansible_ssh_private_key_file=~/.ssh/id_rsa ansible_python_interpreter=/usr/bin/python3 ansible_ssh_common_args='-o StrictHostKeyChecking=no'
```

### **2️⃣ Run Ansible Playbook (`ansible_playbook.yml`)**
```sh
cd ansible
ansible-playbook -i inventory.ini ansible_playbook.yml
```

**What Ansible does:**
- Installs Docker
- Pulls and runs the Flask app as a Docker container


---

# **🐳 Step 3: Running the Flask App with Docker**

### **1️⃣ Dockerfile (flask-app/Dockerfile)**
```Dockerfile
FROM python:3.8
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
CMD [ "python", "app.py" ]
```

### **2️⃣ Build & Run Docker Container**
```sh
cd flask-app
docker build -t flask-app .
docker run -d -p 5000:5000 --name flask-app-container flask-app
```

### **3️⃣ Access the App**
Go to:
```
http://<VM_PUBLIC_IP>:5000/
```


---

# **📌 Step 4: CI/CD Pipeline with GitHub Actions**

### **1️⃣ GitHub Actions Workflow (`.github/workflows/deploy.yml`)**
```yaml
name: Deploy to Azure
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout Code
        uses: actions/checkout@v2
      - name: Login to Azure
        run: az login --service-principal -u ${{ secrets.AZURE_CLIENT_ID }} -p ${{ secrets.AZURE_CLIENT_SECRET }} --tenant ${{ secrets.AZURE_TENANT_ID }}
      - name: Run Ansible Playbook
        run: ansible-playbook -i inventory.ini ansible_playbook.yml
```
✅ **This automates deployment when code is pushed to GitHub!**


---

# **🚀 Troubleshooting**
### **1️⃣ VM Not Accessible via SSH**
```sh
az vm list-ip-addresses -g flask-app-rg -n flask-app-vm
```
If IP changed, update `inventory.ini`.

### **2️⃣ Ansible SSH Permission Denied**
```sh
ssh -i ~/.ssh/id_rsa adminuser@<VM_PUBLIC_IP>
```
Ensure the correct SSH key is used.

### **3️⃣ Flask App Not Running**
```sh
docker ps -a
docker logs flask-app-container
```
Check Docker logs for errors.


---

# **🎯 Summary**
✅ **Terraform creates Azure resources**
✅ **Ansible configures the VM**
✅ **Docker runs the Flask app**
✅ **GitHub Actions automates deployment**

🚀 **Now you can access your Flask app at:**
```
http://<VM_PUBLIC_IP>:5000/
```
---
💡 **Need Help?** Open an issue or reach out for support! 😊🔥

