node 
  {	  	          
	stage ('Workspace Cleanup') {
	  cleanWs()	                          
	}
	stage('Code Checkout')
	{
        git url: 'https://github.com/knagu/WeatherApi-MFE.git', branch: 'main' 
	}
	               
    stage('Build'){        	   
            sh label: '', script: '''                                    
            docker build -t 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi-mfe:$BUILD_NUMBER -f docker/Dockerfile .           
            '''  
            echo "Build Succcessful"     	    
    }
    stage('Push the Docker image'){        
            sh label: '', script: '''                            
            aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin 921881026300.dkr.ecr.us-west-2.amazonaws.com            
            docker push 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi-mfe:$BUILD_NUMBER             
            docker rmi -f 921881026300.dkr.ecr.us-west-2.amazonaws.com/dax-coreinfra-dev-ecr-uswest2-weatherapi-mfe:$BUILD_NUMBER
            '''                      
    }
    stage('Terraform Plan'){                             
        sh label: '', script: '''   
        cd terraform
        sed -i 's/btag/'$BUILD_NUMBER'/g' variables.tf
        terraform init
        echo "yes" | terraform plan 
        '''          
     }  
     stage('Terraform Apply'){  
       timeout(time: 10, unit: 'MINUTES') {
        input message: "Do you want to proceed for deployment?"
       }    
        sh label: '', script: '''   
        cd terraform
        echo "yes" | terraform apply
        '''          
     }               
  }
