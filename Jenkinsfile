#!/usr/bin/env groovy

//library "cloud-jenkins-common-libraries@master"

def labelId = "${UUID.randomUUID().toString()}"
def label = "Kubernetes-ami-pr-${labelId}"

def installTools() {
  sh '''
    yum install -y yum-utils
    yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
    yum -y install packer jq tar gzip
  '''
}

secrets = [
  [
    $class: 'VaultSecret', path: 'secret/aws/devaccount', secretValues: [
      [$class: 'VaultSecretValue', envVar: 'AWS_ACCESS_KEY_ID', vaultKey: 'AWS_ACCESS_KEY_ID'],
      [$class: 'VaultSecretValue', envVar: 'AWS_SECRET_ACCESS_KEY', vaultKey: 'AWS_SECRET_ACCESS_KEY'],
    ]
  ]
]

podTemplate(name: label, label: label, nodeSelector: 'function=workers', containers: [
  containerTemplate(name: 'aws-cli', image: 'amazon/aws-cli:latest', alwaysPullImage: true, ttyEnabled: true, command: '/bin/bash'),
]) {
  node(label) {
    stage('Git checkout repos') {
        def scmVars = checkout(scm)
        env.GIT_COMMIT = "${scmVars.GIT_COMMIT}"
        env.GIT_BRANCH = "${scmVars.GIT_BRANCH}"
    }

    stage('ImageBuilder') {
      container('aws-cli') {
        installTools()
        if (env.GIT_BRANCH == "master") {
            env.AWS_SHARED_ACCOUNTS = ""
            env.AWS_CROSS_ACCOUNT_ROLE = ""
        }

        withVault([vaultSecrets: secrets]) {
          sh(
            script: "make all",
            returnStdout: false
          )
          sh(
            script: "make all arch=arm64",
            returnStdout: false
          )
        }
      }
    }
  }
}
