.DEFAULT: all

.PHONY: all
all: genpri genpub gencsr gencrt

# 生成私钥，密钥长度为1024bit，也可以是2048bit，用aes128加密私钥，密码为12345678
.PHONY: genpri
genpri:
	openssl genrsa -passout pass:12345678 -aes128 -out fd.key 1024

# 根据私钥生成公钥
.PHONY: genpub
genpub:
	openssl rsa -in fd.key -passin pass:12345678 -pubout -out fd-public.key

# 创建证书CSR请求，签名哈希算法使用md5
.PHONY: gencsr
gencsr:
	openssl req -new -key fd.key -passin pass:12345678 -out fd.csr -config config.cnf -md5 \
	-subj "/C=CN/ST=BJ/L=BJ/O=YY/OU=XXZX/CN=lianyz/emailAddress=lianyz@email.cn"

# 生成证书
.PHONY: gencrt
gencrt:
	openssl x509 -req -days 36500 -in fd.csr -signkey fd.key -passin pass:12345678 -md5 -out fd.crt \
	-extfile config.cnf -extensions v3_req

# 查看证书
.PHONY: print
print:
	@echo "\nPrint Private Key:\n"
	openssl rsa -in fd.key -noout -text -passin pass:12345678

	@echo "\nPrint Certificate Rqeust:\n"
	openssl req -in fd.csr -noout -text

	@echo "\nPrint Certificate:\n"
	openssl x509 -in fd.crt -noout -text

.PHONY: clean
clean:
	rm fd*