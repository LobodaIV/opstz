node {
    git 'https://github.com/LobodaIV/opstz.git'
    try {
        stage('Build') {
            sh 'cd ~;pwd'
	    runRes = sh(returnStatus: true, script: "docker-machine create --driver amazonec2 --amazonec2-open-port 80 --amazonec2-region eu-west-1 --amazonec2-zone 'c' aws-nginx-instance")
			if(!runRes) {
				sh(returnStatus: true, script: "docker-machine create --driver amazonec2 --amazonec2-open-port 80 --amazonec2-region eu-west-1 --amazonec2-zone 'c' aws-nginx-instance")
			    sh 'eval $(docker-machine env aws-nginx-instance --shell bash); docker run -d -p 80:80 libroli1988/opstz'
			} else {
			    sh 'eval $(docker-machine env aws-nginx-instance --shell bash); docker run -d -p 80:80 libroli1988/opstz'
			}
		}
    } finally {
         stage 'Clean up'
         sh 'echo "clean up"'
    }
}
