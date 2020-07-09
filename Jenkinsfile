pipeline {
	agent any
	stages {

        stage('Lint HTML') {
			steps {
				sh 'tidy -q -e *.html'
			}
		}

        stage('Build Docker Image') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]){
					sh '''
						docker build -t $DOCKER_USERNAME/capstone .
					'''
				}
			}
		}

		stage('Push Image To Dockerhub') {
			steps {
				withCredentials([usernamePassword(credentialsId: 'dockerhub', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]){
					sh '''
						docker login -u $DOCKER_USERNAME -p $DOCKER_PASSWORD
						docker push $DOCKER_USERNAME/capstone
					'''
				}
			}
		}

        stage('Create cluster') {
            steps {
                withAWS(credentials: 'aws-static', region: 'us-west-2') {
                    sh "eksctl create cluster --name capstonecluster --version 1.16 --region us-west-2 --without-nodegroup"
                }
            }
        }

		stage('Create node group') {
            steps {
                withAWS(credentials: 'aws-static', region: 'us-west-2') {
                    sh "eksctl create nodegroup --cluster capstonecluster --version auto --name standard-workers --node-type t3.micro --node-ami auto --nodes 3 --nodes-min 1 --nodes-max 4 --region us-west-2 --ssh-public-key udacity-oregon-course"
                }
            }
        }

		stage('Configuring') {
			steps {
				withAWS(credentials: 'aws-static', region: 'us-west-2') {
					sh '''
						aws eks --region us-west-2 update-kubeconfig --name capstonecluster
						chmod +x aws/replaceARNrole.sh
						./aws/replaceARNrole.sh
						cat aws/aws-auth-cm.yaml
					'''
				}
			}
		}

		stage('Deploying') {
			steps {
				withAWS(credentials: 'aws-static', region: 'us-west-2') {
					sh '''
						kubectl get nodes
						kubectl apply -f aws/aws-auth-cm.yaml
						kubectl apply -f aws/capstone-app-deployment.yml
						kubectl apply -f aws/load-balancer.yml
						kubectl get pods
						kubectl get svc
					'''
				}
			}
		}

		stage('Getting nodes,pods,services') {
			steps {
				withAWS(credentials: 'aws-static', region: 'us-west-2') {
					sh '''

						kubectl get nodes
						kubectl get pods
						kubectl get svc
					'''
				}
			}
		}
	}
}
