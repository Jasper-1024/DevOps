# ansible

ansible 汇总, 以初始化为主;

需要先在 host 中配完毕 ssh key 登录;

```bash
# 详细输出模式
ansible-playbook -i inventory/hosts.ini playbooks/init.yaml -v
# 测试运行(不实际执行)
ansible-playbook -i inventory/hosts.ini playbooks/init.yaml --check
# 实际执行
ansible-playbook -i inventory/hosts.ini playbooks/init.yaml
```

## init.yaml

初始化 zsh 环境

配置 swap

配置 bbr 等加速

安装配置 fail2ban

安装配置 CSF
