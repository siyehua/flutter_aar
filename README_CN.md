# flutter_aar

一个可以直接使用本地 aar 文件的 gradle task

## 开始使用
1. 复制下面代码, 到 `插件项目路径/android/build.gradle` 顶侧:

```groovy
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
```

2. 复制下面代码, 到 `插件项目路径/android/build.gradle` 的最后面: 

```groovy
String aarPath = localMavenPath
task useAar {
    File file = project.file("libs")
    if (file.exists() && file.isDirectory()) {
        file.listFiles(new FileFilter() {
            @Override
            boolean accept(File pathname) {
                return pathname.name.endsWith(".aar")
            }
        }).each { item ->
            String aarName = item.name.substring(0, item.name.length() - 4)
            String[] aarInfo = aarName.split("-")
            String sha1 = getFileSha1(item)
            String md5 = getFileMD5(item)
            println("aar: " + aarInfo + " file sha1:" + sha1 + " md5:" + md5)
            String fromStr = item.path
            String intoStr = aarPath + "/" + aarInfo[0].replace(".", "/") + "/" + aarInfo[1] + "/" + aarInfo[2]
            String newName = aarInfo[1] + "-" + aarInfo[2] + ".aar"

            project.copy {
                from fromStr
                into intoStr
                rename(item.name, newName)
            }

            project.file(intoStr + "/" + newName + ".md5").write(md5)
            project.file(intoStr + "/" + newName + ".sha1").write(sha1)

            String pomPath = intoStr + "/" + newName.substring(0, newName.length() - 4) + ".pom"
            project.file(pomPath).write(createPomStr(aarInfo[0], aarInfo[1], aarInfo[2]))
            project.file(pomPath + ".md5").write(getFileMD5(project.file(pomPath)))
            project.file(pomPath + ".sha1").write(getFileSha1(project.file(pomPath)))

            String metadataPath = project.file(intoStr).getParentFile().path + "/maven-metadata.xml"
            project.file(metadataPath).write(createMetadataStr(aarInfo[0], aarInfo[1], aarInfo[2]))
            project.file(metadataPath + ".md5").write(getFileMD5(project.file(metadataPath)))
            project.file(metadataPath + ".sha1").write(getFileSha1(project.file(metadataPath)))
            dependencies {
                implementation "${aarInfo[0]}:${aarInfo[1]}:${aarInfo[2]}"
            }
        }
    }
}

public static String createMetadataStr(String groupId, String artifactId, String version) {
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<metadata>\n" +
            "  <groupId>$groupId</groupId>\n" +
            "  <artifactId>$artifactId</artifactId>\n" +
            "  <versioning>\n" +
            "    <release>$version</release>\n" +
            "    <versions>\n" +
            "      <version>$version</version>\n" +
            "    </versions>\n" +
            "    <lastUpdated>${new Date().format('yyyyMMdd')}000000</lastUpdated>\n" +
            "  </versioning>\n" +
            "</metadata>\n"
}

public static String createPomStr(String groupId, String artifactId, String version) {
    return "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
            "<project xsi:schemaLocation=\"http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd\" xmlns=\"http://maven.apache.org/POM/4.0.0\"\n" +
            "    xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n" +
            "  <modelVersion>4.0.0</modelVersion>\n" +
            "  <groupId>$groupId</groupId>\n" +
            "  <artifactId>$artifactId</artifactId>\n" +
            "  <version>$version</version>\n" +
            "  <packaging>aar</packaging>\n" +
            "</project>\n"
}

public static String getFileSha1(File file) {
    FileInputStream input = null;
    try {
        input = new FileInputStream(file);
        MessageDigest digest = MessageDigest.getInstance("SHA-1");
        byte[] buffer = new byte[1024 * 1024 * 10];

        int len = 0;
        while ((len = input.read(buffer)) > 0) {
            digest.update(buffer, 0, len);
        }
        String sha1 = new BigInteger(1, digest.digest()).toString(16);
        int length = 40 - sha1.length();
        if (length > 0) {
            for (int i = 0; i < length; i++) {
                sha1 = "0" + sha1;
            }
        }
        return sha1;
    }
    catch (IOException e) {
        System.out.println(e);
    }
    catch (NoSuchAlgorithmException e) {
        System.out.println(e);
    }
    finally {
        try {
            if (input != null) {
                input.close();
            }
        }
        catch (IOException e) {
            System.out.println(e);
        }
    }
}

public static String getFileMD5(File file) {
    FileInputStream input = null;
    try {
        input = new FileInputStream(file);
        MessageDigest digest = MessageDigest.getInstance("MD5");
        byte[] buffer = new byte[1024 * 1024 * 10];

        int len = 0;
        while ((len = input.read(buffer)) > 0) {
            digest.update(buffer, 0, len);
        }
        String md5 = new BigInteger(1, digest.digest()).toString(16);
        int length = 32 - md5.length();
        if (length > 0) {
            for (int i = 0; i < length; i++) {
                md5 = "0" + md5;
            }
        }
        return md5;
    }
    catch (IOException e) {
        System.out.println(e);
    }
    catch (NoSuchAlgorithmException e) {
        System.out.println(e);
    }
    finally {
        try {
            if (input != null) {
                input.close();
            }
        }
        catch (IOException e) {
            System.out.println(e);
        }
    }
}
```

3. 修改刚才文件的 `repositories`, 添加自定义仓库地址 :

```groovy
String localMavenPath = project.mkdir("build").absolutePath
rootProject.allprojects {
    repositories {
        maven { url "file://$localMavenPath" }
    }
}
```

4. 复制你的 aar 文件到 `libs` 目录

注意, aar 的文件格式必须是:  `groupId-artifactId-version.aar`

例如:

```
com.siyehua.flataar-mylibrary2-1.0.2.aar
```

### 现在你就可以使用本地 aar 文件了.

详细例子请看 [build.gradle](https://github.com/siyehua/flutter_aar/blob/main/android/build.gradle)

## 注意

不要在 `dependencies` 直接添加下面的代码, task 会自动添加:

```
implementation fileTree(include: ['*.jar'], dir: 'libs')
```

或者:

```
implementation(name: 'com.siyehua.flataar-mylibrary2-1.0.2', ext: 'aar')

```

这种方式会被认定为本地 aar, 编译无法通过
