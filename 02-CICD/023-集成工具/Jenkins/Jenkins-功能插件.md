# Jenkins 功能插件

## 邮件反馈

- https://plugins.jenkins.io/email-ext/
- <https://github.com/jenkinsci/email-ext-plugin>

``` groovy
stage('Email') {
    steps {
        script {
            def mailRecipients = 'XXX@xxxxx.xxx-domain'
            def jobName = currentBuild.fullDisplayName
            emailext body: '''${SCRIPT, template="groovy-html.template"}''',
            mimeType: 'text/html',
            subject: "[Jenkins] ${jobName}",
            to: "${mailRecipients}",
            replyTo: "${mailRecipients}",
            recipientProviders: [[$class: 'CulpritsRecipientProvider']]
        }
    }
}
```