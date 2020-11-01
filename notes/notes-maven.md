### 打包
```
<!-- 打JAR包 -->
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <configuration>
            <!-- 不打包资源文件（配置文件和依赖包分开） -->
            <excludes>
                <exclude>*.**</exclude>
                <exclude>*/*.xml</exclude>
            </excludes>
            <archive>
                <manifest>
                    <addClasspath>true</addClasspath>
                    <!-- MANIFEST.MF 中 Class-Path 加入前缀 -->
                    <classpathPrefix>lib/</classpathPrefix>
                    <!-- jar包不包含唯一版本标识 -->
                    <useUniqueVersions>false</useUniqueVersions>
                    <!--指定入口类 -->
                    <mainClass>site.yuyanjia.template.Application</mainClass>
                </manifest>
                <manifestEntries>
                    <!--MANIFEST.MF 中 Class-Path 加入资源文件目录 -->
                    <Class-Path>./resources/</Class-Path>
                </manifestEntries>
            </archive>
            <outputDirectory>${project.build.directory}</outputDirectory>
        </configuration>
    </plugin>

    <!-- 该插件的作用是用于复制依赖的jar包到指定的文件夹里 -->
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-dependency-plugin</artifactId>
        <executions>
            <execution>
                <id>copy-dependencies</id>
                <phase>package</phase>
                <goals>
                    <goal>copy-dependencies</goal>
                </goals>
                <configuration>
                    <outputDirectory>${project.build.directory}/lib/</outputDirectory>
                </configuration>
            </execution>
        </executions>
    </plugin>

    <!-- 该插件的作用是用于复制指定的文件 -->
    <plugin>
        <artifactId>maven-resources-plugin</artifactId>
        <executions>
            <execution> <!-- 复制配置文件 -->
                <id>copy-resources</id>
                <phase>package</phase>
                <goals>
                    <goal>copy-resources</goal>
                </goals>
                <configuration>
                    <resources>
                        <resource>
                            <directory>src/main/resources</directory>
                            <includes>
                                <!-- <include>*.properties</include> -->
                            </includes>
                        </resource>
                    </resources>
                    <outputDirectory>${project.build.directory}/resources</outputDirectory>
                </configuration>
            </execution>
        </executions>
    </plugin>

    <!-- SpringBoot 打包插件，把 maven-jar-plugin 打成的jar包重新打成可运行jar包 -->
    <plugin>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-maven-plugin</artifactId>
        <configuration>
            <!--重写包含依赖，包含不存在的依赖，jar里没有pom里的依赖 -->
            <includes>
                <include>
                    <groupId>null</groupId>
                    <artifactId>null</artifactId>
                </include>
            </includes>
            <layout>ZIP</layout>
            <!--使用外部配置文件，jar包里没有资源文件 -->
            <addResources>true</addResources>
            <outputDirectory>${project.build.directory}/resources</outputDirectory>
        </configuration>
        <executions>
            <execution>
                <goals>
                    <goal>repackage</goal>
                </goals>
                <configuration>
                    <!--配置jar包特殊标识 配置后，保留原文件，生成新文件 *-run.jar -->
                    <!--配置jar包特殊标识 不配置，原文件命名为 *.jar.original，生成新文件 *.jar -->
                    <!--<classifier>run</classifier> -->
                </configuration>
            </execution>
        </executions>
    </plugin>
```
### scala插件
```
<build>
        <plugins>
            <plugin>
                <groupId>net.alchim31.maven</groupId>
                <artifactId>scala-maven-plugin</artifactId>
                <version>4.4.0</version>
                <executions>
                    <execution>
                        <goals>
                            <goal>compile</goal>
                            <goal>testCompile</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-assembly-plugin</artifactId>
                <version>3.0.0</version>
                <executions>
                    <execution>
                        <id>make-assembly</id>
                        <phase>package</phase>
                        <goals>
                            <goal>single</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```

命令行下载jar包

```
方法一：
mvn dependency:get -DremoteRepositories=https://mvnrepository.com/artifact/com.fasterxml.jackson.datatype/jackson-datatype-jsr310 -DgroupId=com.fasterxml.jackson.datatype -DartifactId=jackson-datatype-jsr310 -Dversion=2.11.3

方法二：
创建pom.xml文件
mvn -f pom.xml dependency:copy-dependencies
```

