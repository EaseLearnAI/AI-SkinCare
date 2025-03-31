将 Neon 连接到你的堆栈
了解如何将 Neon 集成到你的应用程序中

使用 Neon 作为技术堆栈中的无服务器数据库意味着配置连接。无论是来自语言或框架的直接连接字符串、为部署平台设置环境变量、连接到 Prisma 等 ORM，还是为 CI/CD 工作流配置部署设置，一切都从连接开始。

连接到您的应用程序
本节提供各种框架和语言的连接字符串示例，帮助您将 Neon 集成到您的技术堆栈中。

查询语言
.env
Next.js
细雨
棱镜
Python
。网
红宝石
锈
去
# .env example
PGHOST=hostname
PGDATABASE=database
PGUSER=username
PGPASSWORD=password
PGPORT=5432
获取连接详细信息
从应用程序或客户端连接到 Neon 时，您将连接到 Neon 项目中的数据库。在 Neon 中，数据库属于一个分支，该分支可能是项目的默认分支 ( main) 或子分支。

您可以通过单击项目仪表板上的“连接”按钮打开“连接到数据库”模式来获取所需的数据库连接详细信息。选择一个分支、一个计算、一个数据库和一个角色。将为您构建一个连接字符串。

连接详细信息模式

Neon 支持与数据库的池化和直接连接。如果您的应用程序使用大量并发连接，请使用池化连接字符串。有关更多信息，请参阅连接池。

Neon 连接字符串包括角色、密码、主机名和数据库名称。

postgresql://alex:AbC123dEf@ep-cool-darkness-a1b2c3d4-pooler.us-east-2.aws.neon.tech/dbname?sslmode=require
             ^    ^         ^                         ^                              ^
       role -|    |         |- hostname               |- pooler option               |- database
                  |
                  |- password
笔记
主机名包含计算的 ID，其ep-前缀为：ep-cool-darkness-a1b2c3d4。有关 Neon 连接字符串的更多信息，请参阅
连接字符串
。

使用连接详细信息
您可以使用连接字符串中的详细信息或连接字符串本身来配置连接。例如，您可以将连接详细信息放在.env文件中、将连接字符串分配给变量或在命令行上传递连接字符串。

.env文件
PGUSER=alex
PGHOST=ep-cool-darkness-a1b2c3d4.us-east-2.aws.neon.tech
PGDATABASE=dbname
PGPASSWORD=AbC123dEf
PGPORT=5432
多变的
DATABASE_URL="postgresql://alex:AbC123dEf@ep-cool-darkness-a1b2c3d4.us-east-2.aws.neon.tech/dbname"
命令行
psql postgresql://alex:AbC123dEf@ep-cool-darkness-a1b2c3d4.us-east-2.aws.neon.tech/dbname
笔记
sslmodeNeon 要求所有连接都使用 SSL/TLS 加密，但您可以通过将参数设置附加到连接字符串来提高保护级别。有关说明，请参阅安全连接到 Neon。

常见问题解答
我从哪里获得密码？
它包含在您的 Neon 连接字符串中，您可以通过单击项目仪表板上的“连接”按钮来打开“连接到数据库”模式来找到它。

Neon 使用哪个端口？
Neon 使用默认的 Postgres 端口5432。

网络协议支持
在 AWS 上配置的 Neon 项目支持
IPv4
和
IPv6
地址。Azure 上配置的 Neon 项目目前仅支持 IPv4。

此外，Neon 还提供了支持 WebSocket 和 HTTP 连接的无服务器驱动程序。有关更多信息，请参阅我们的Neon 无服务器驱动程序文档。

连接说明
一些较旧的客户端库和驱动程序（包括较旧的psql可执行文件）在构建时并未
服务器名称指示 (SNI)
支持并需要解决方法。有关更多信息，请参阅连接错误。
某些使用 pgJDBC 驱动程序连接到 Postgres 的基于 Java 的工具（例如 DBeaver、DataGrip 和 CLion）不支持在数据库连接字符串或 URL 字段中包含角色名称和密码。当您发现连接字符串不被接受时，请尝试在工具的连接 UI 中的相应字段中输入数据库名称、角色和密码值


将 Neon 连接到你的堆栈
了解如何将 Neon 集成到你的应用程序中

使用 Neon 作为技术堆栈中的无服务器数据库意味着配置连接。无论是来自语言或框架的直接连接字符串、为部署平台设置环境变量、连接到 Prisma 等 ORM，还是为 CI/CD 工作流配置部署设置，一切都从连接开始。

连接到您的应用程序
本节提供各种框架和语言的连接字符串示例，帮助您将 Neon 集成到您的技术堆栈中。

查询语言
.env
Next.js
细雨
棱镜
Python
。网
红宝石
锈
去
# .env example
PGHOST=hostname
PGDATABASE=database
PGUSER=username
PGPASSWORD=password
PGPORT=5432
获取连接详细信息
从应用程序或客户端连接到 Neon 时，您将连接到 Neon 项目中的数据库。在 Neon 中，数据库属于一个分支，该分支可能是项目的默认分支 ( main) 或子分支。

您可以通过单击项目仪表板上的“连接”按钮打开“连接到数据库”模式来获取所需的数据库连接详细信息。选择一个分支、一个计算、一个数据库和一个角色。将为您构建一个连接字符串。

连接详细信息模式

Neon 支持与数据库的池化和直接连接。如果您的应用程序使用大量并发连接，请使用池化连接字符串。有关更多信息，请参阅连接池。

Neon 连接字符串包括角色、密码、主机名和数据库名称。

postgresql://alex:AbC123dEf@ep-cool-darkness-a1b2c3d4-pooler.us-east-2.aws.neon.tech/dbname?sslmode=require
             ^    ^         ^                         ^                              ^
       role -|    |         |- hostname               |- pooler option               |- database
                  |
                  |- password
笔记
主机名包含计算的 ID，其ep-前缀为：ep-cool-darkness-a1b2c3d4。有关 Neon 连接字符串的更多信息，请参阅
连接字符串
。

使用连接详细信息
您可以使用连接字符串中的详细信息或连接字符串本身来配置连接。例如，您可以将连接详细信息放在.env文件中、将连接字符串分配给变量或在命令行上传递连接字符串。

.env文件
PGUSER=alex
PGHOST=ep-cool-darkness-a1b2c3d4.us-east-2.aws.neon.tech
PGDATABASE=dbname
PGPASSWORD=AbC123dEf
PGPORT=5432
多变的
DATABASE_URL="postgresql://alex:AbC123dEf@ep-cool-darkness-a1b2c3d4.us-east-2.aws.neon.tech/dbname"
命令行
psql postgresql://alex:AbC123dEf@ep-cool-darkness-a1b2c3d4.us-east-2.aws.neon.tech/dbname
笔记
sslmodeNeon 要求所有连接都使用 SSL/TLS 加密，但您可以通过将参数设置附加到连接字符串来提高保护级别。有关说明，请参阅安全连接到 Neon。

常见问题解答
我从哪里获得密码？
它包含在您的 Neon 连接字符串中，您可以通过单击项目仪表板上的“连接”按钮来打开“连接到数据库”模式来找到它。

Neon 使用哪个端口？
Neon 使用默认的 Postgres 端口5432。

网络协议支持
在 AWS 上配置的 Neon 项目支持
IPv4
和
IPv6
地址。Azure 上配置的 Neon 项目目前仅支持 IPv4。

此外，Neon 还提供了支持 WebSocket 和 HTTP 连接的无服务器驱动程序。有关更多信息，请参阅我们的Neon 无服务器驱动程序文档。

连接说明
一些较旧的客户端库和驱动程序（包括较旧的psql可执行文件）在构建时并未
服务器名称指示 (SNI)
支持并需要解决方法。有关更多信息，请参阅连接错误。
某些使用 pgJDBC 驱动程序连接到 Postgres 的基于 Java 的工具（例如 DBeaver、DataGrip 和 CLion）不支持在数据库连接字符串或 URL 字段中包含角色名称和密码。当您发现连接字符串不被接受时，请尝试在工具的连接 UI 中的相应字段中输入数据库名称、角色和密码值