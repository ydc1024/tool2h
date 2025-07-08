#!/bin/bash

# 修复Composer依赖问题和500错误
# 解决vendor目录损坏导致的Laravel启动失败

echo "🔧 修复Composer依赖问题和500错误"
echo "================================"
echo "问题：Composer卸载失败 → vendor目录损坏 → 500错误"
echo "解决：清理+重装+权限修复"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    log_error "请使用 root 用户或 sudo 运行此脚本"
    exit 1
fi

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"
BACKUP_DIR="/var/www/besthammer_c_usr/data/backups"

log_step "第1步：诊断当前问题"
echo "-----------------------------------"

cd "$PROJECT_DIR"

# 检查vendor目录状态
if [ -d "vendor" ]; then
    log_warning "vendor目录存在但可能已损坏"
    VENDOR_SIZE=$(du -sh vendor 2>/dev/null | cut -f1)
    log_info "vendor目录大小: $VENDOR_SIZE"
    
    # 检查autoload.php
    if [ -f "vendor/autoload.php" ]; then
        log_info "autoload.php存在"
    else
        log_error "autoload.php缺失 - 这是500错误的直接原因"
    fi
else
    log_error "vendor目录不存在"
fi

# 检查composer.lock
if [ -f "composer.lock" ]; then
    log_info "composer.lock存在"
else
    log_warning "composer.lock不存在"
fi

# 测试当前网站状态
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club" 2>/dev/null || echo "000")
log_info "当前网站状态: HTTP $HTTP_STATUS"

log_step "第2步：停止可能占用文件的进程"
echo "-----------------------------------"

# 停止可能的Laravel队列进程
log_info "停止Laravel相关进程..."
pkill -f "artisan queue" || true
pkill -f "artisan serve" || true

# 停止Apache以释放文件锁
log_info "重启Apache释放文件锁..."
systemctl restart apache2
sleep 2

log_step "第3步：强制清理损坏的vendor目录"
echo "-----------------------------------"

# 备份composer.json和composer.lock
if [ -f "composer.json" ]; then
    cp composer.json composer.json.backup
    log_success "composer.json已备份"
fi

if [ -f "composer.lock" ]; then
    cp composer.lock composer.lock.backup
    log_success "composer.lock已备份"
fi

# 强制删除vendor目录
if [ -d "vendor" ]; then
    log_info "强制删除损坏的vendor目录..."
    
    # 修改权限以确保可以删除
    chmod -R 777 vendor 2>/dev/null || true
    chown -R root:root vendor 2>/dev/null || true
    
    # 强制删除
    rm -rf vendor
    
    if [ -d "vendor" ]; then
        log_warning "vendor目录删除失败，尝试更强力的方法..."
        find vendor -type f -exec rm -f {} \; 2>/dev/null || true
        find vendor -type d -exec rmdir {} \; 2>/dev/null || true
        rm -rf vendor 2>/dev/null || true
    fi
    
    if [ ! -d "vendor" ]; then
        log_success "vendor目录已成功删除"
    else
        log_error "vendor目录删除失败，需要手动处理"
    fi
else
    log_info "vendor目录不存在，跳过删除"
fi

# 删除composer.lock以强制重新解析依赖
if [ -f "composer.lock" ]; then
    rm -f composer.lock
    log_info "已删除composer.lock，将重新解析依赖"
fi

log_step "第4步：清理Composer缓存"
echo "-----------------------------------"

# 清理Composer缓存
log_info "清理Composer缓存..."
sudo -u besthammer_c_usr composer clear-cache 2>/dev/null || composer clear-cache

# 清理系统临时文件
log_info "清理系统临时文件..."
rm -rf /tmp/composer-* 2>/dev/null || true

log_step "第5步：重新安装Composer依赖"
echo "-----------------------------------"

# 确保composer.json存在
if [ ! -f "composer.json" ]; then
    log_error "composer.json不存在，无法继续"
    exit 1
fi

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr "$PROJECT_DIR"
chmod -R 755 "$PROJECT_DIR"

# 重新安装依赖
log_info "重新安装Composer依赖..."
sudo -u besthammer_c_usr composer install --no-dev --optimize-autoloader --no-interaction

# 检查安装结果
if [ -f "vendor/autoload.php" ]; then
    log_success "Composer依赖安装成功"
else
    log_error "Composer依赖安装失败"
    
    # 尝试使用不同的方法
    log_info "尝试使用--no-scripts参数重新安装..."
    sudo -u besthammer_c_usr composer install --no-dev --optimize-autoloader --no-scripts --no-interaction
    
    if [ -f "vendor/autoload.php" ]; then
        log_success "使用--no-scripts参数安装成功"
    else
        log_error "所有安装方法都失败了"
        exit 1
    fi
fi

log_step "第6步：修复Laravel配置"
echo "-----------------------------------"

# 确保.env文件存在
if [ ! -f ".env" ]; then
    if [ -f ".env.example" ]; then
        cp .env.example .env
        log_info "已从.env.example创建.env文件"
    else
        log_error ".env文件不存在且无法创建"
    fi
fi

# 生成应用密钥
log_info "生成应用密钥..."
sudo -u besthammer_c_usr php artisan key:generate --force 2>/dev/null || {
    log_warning "artisan命令失败，尝试直接生成密钥..."
    
    # 手动生成APP_KEY
    APP_KEY="base64:$(openssl rand -base64 32)"
    sed -i "s/APP_KEY=.*/APP_KEY=$APP_KEY/" .env
    log_info "手动生成APP_KEY: $APP_KEY"
}

# 创建必要的目录
mkdir -p storage/logs
mkdir -p storage/framework/cache
mkdir -p storage/framework/sessions
mkdir -p storage/framework/views
mkdir -p bootstrap/cache

# 设置storage权限
chmod -R 775 storage
chmod -R 775 bootstrap/cache
chown -R besthammer_c_usr:besthammer_c_usr storage
chown -R besthammer_c_usr:besthammer_c_usr bootstrap/cache

log_step "第7步：清理和重建缓存"
echo "-----------------------------------"

# 清理所有缓存
log_info "清理Laravel缓存..."
sudo -u besthammer_c_usr php artisan config:clear 2>/dev/null || true
sudo -u besthammer_c_usr php artisan cache:clear 2>/dev/null || true
sudo -u besthammer_c_usr php artisan route:clear 2>/dev/null || true
sudo -u besthammer_c_usr php artisan view:clear 2>/dev/null || true

# 重建缓存
log_info "重建生产环境缓存..."
sudo -u besthammer_c_usr php artisan config:cache 2>/dev/null || true
sudo -u besthammer_c_usr php artisan route:cache 2>/dev/null || true

log_step "第8步：创建诊断页面"
echo "-----------------------------------"

# 创建详细的诊断页面
cat > public/fix-diagnosis.php << 'EOF'
<?php
header('Content-Type: text/html; charset=utf-8');

// 检查autoload
$autoloadExists = file_exists(__DIR__ . '/../vendor/autoload.php');
$canRequireAutoload = false;

if ($autoloadExists) {
    try {
        require_once __DIR__ . '/../vendor/autoload.php';
        $canRequireAutoload = true;
    } catch (Exception $e) {
        $autoloadError = $e->getMessage();
    }
}

// 检查Laravel
$laravelWorks = false;
if ($canRequireAutoload) {
    try {
        $app = require_once __DIR__ . '/../bootstrap/app.php';
        $laravelWorks = true;
    } catch (Exception $e) {
        $laravelError = $e->getMessage();
    }
}
?>
<!DOCTYPE html>
<html>
<head>
    <title>🔧 Composer修复诊断</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #f8f9fa; }
        .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); }
        .success { color: #28a745; font-weight: bold; }
        .error { color: #dc3545; font-weight: bold; }
        .warning { color: #ffc107; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; margin: 20px 0; }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
        .status-ok { background-color: #d4f6d4; }
        .status-error { background-color: #f8d7da; }
        pre { background: #f8f9fa; padding: 15px; border-radius: 5px; overflow-x: auto; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🔧 Composer修复诊断报告</h1>
        
        <div style="background: <?php echo $laravelWorks ? '#d4f6d4' : '#f8d7da'; ?>; padding: 20px; border-radius: 10px; margin: 20px 0;">
            <h3><?php echo $laravelWorks ? '✅ 修复成功' : '❌ 仍有问题'; ?></h3>
            <p><?php echo $laravelWorks ? 'Laravel应用现在可以正常运行！' : '还需要进一步修复。'; ?></p>
        </div>
        
        <h2>详细诊断结果</h2>
        <table>
            <tr><th>检查项目</th><th>状态</th><th>详情</th></tr>
            
            <tr class="<?php echo $autoloadExists ? 'status-ok' : 'status-error'; ?>">
                <td>vendor/autoload.php</td>
                <td><?php echo $autoloadExists ? '✅ 存在' : '❌ 不存在'; ?></td>
                <td><?php echo $autoloadExists ? '文件存在' : 'Composer依赖未正确安装'; ?></td>
            </tr>
            
            <tr class="<?php echo $canRequireAutoload ? 'status-ok' : 'status-error'; ?>">
                <td>Autoload加载</td>
                <td><?php echo $canRequireAutoload ? '✅ 正常' : '❌ 失败'; ?></td>
                <td><?php echo $canRequireAutoload ? '可以正常加载' : (isset($autoloadError) ? $autoloadError : '无法加载'); ?></td>
            </tr>
            
            <tr class="<?php echo $laravelWorks ? 'status-ok' : 'status-error'; ?>">
                <td>Laravel应用</td>
                <td><?php echo $laravelWorks ? '✅ 正常' : '❌ 失败'; ?></td>
                <td><?php echo $laravelWorks ? 'Laravel应用正常启动' : (isset($laravelError) ? $laravelError : '无法启动'); ?></td>
            </tr>
            
            <tr class="status-ok">
                <td>PHP版本</td>
                <td>✅ <?php echo PHP_VERSION; ?></td>
                <td>PHP版本正常</td>
            </tr>
            
            <tr class="<?php echo is_writable(__DIR__ . '/../storage') ? 'status-ok' : 'status-error'; ?>">
                <td>Storage权限</td>
                <td><?php echo is_writable(__DIR__ . '/../storage') ? '✅ 可写' : '❌ 不可写'; ?></td>
                <td><?php echo is_writable(__DIR__ . '/../storage') ? '权限正常' : '需要修复权限'; ?></td>
            </tr>
        </table>
        
        <h2>文件系统检查</h2>
        <table>
            <tr><th>文件/目录</th><th>状态</th><th>大小/权限</th></tr>
            <tr>
                <td>vendor/</td>
                <td><?php echo is_dir(__DIR__ . '/../vendor') ? '✅ 存在' : '❌ 不存在'; ?></td>
                <td><?php echo is_dir(__DIR__ . '/../vendor') ? '目录存在' : '目录缺失'; ?></td>
            </tr>
            <tr>
                <td>composer.json</td>
                <td><?php echo file_exists(__DIR__ . '/../composer.json') ? '✅ 存在' : '❌ 不存在'; ?></td>
                <td><?php echo file_exists(__DIR__ . '/../composer.json') ? filesize(__DIR__ . '/../composer.json') . ' bytes' : '文件缺失'; ?></td>
            </tr>
            <tr>
                <td>composer.lock</td>
                <td><?php echo file_exists(__DIR__ . '/../composer.lock') ? '✅ 存在' : '❌ 不存在'; ?></td>
                <td><?php echo file_exists(__DIR__ . '/../composer.lock') ? filesize(__DIR__ . '/../composer.lock') . ' bytes' : '文件缺失'; ?></td>
            </tr>
            <tr>
                <td>.env</td>
                <td><?php echo file_exists(__DIR__ . '/../.env') ? '✅ 存在' : '❌ 不存在'; ?></td>
                <td><?php echo file_exists(__DIR__ . '/../.env') ? filesize(__DIR__ . '/../.env') . ' bytes' : '文件缺失'; ?></td>
            </tr>
        </table>
        
        <?php if (!$laravelWorks): ?>
        <div style="background: #fff3cd; padding: 20px; border-radius: 10px; margin: 20px 0; border-left: 5px solid #ffc107;">
            <h4>🔧 下一步修复建议</h4>
            <ol>
                <li>如果vendor目录不存在：运行 <code>composer install</code></li>
                <li>如果权限有问题：运行 <code>chmod -R 775 storage bootstrap/cache</code></li>
                <li>如果.env文件有问题：运行 <code>php artisan key:generate</code></li>
                <li>清理缓存：运行 <code>php artisan config:clear</code></li>
            </ol>
        </div>
        <?php endif; ?>
        
        <div style="text-align: center; margin: 30px 0;">
            <a href="/" style="display: inline-block; padding: 10px 20px; background: #007bff; color: white; text-decoration: none; border-radius: 5px;">🏠 尝试访问首页</a>
        </div>
        
        <hr style="margin: 30px 0;">
        <p style="text-align: center; color: #6c757d;">
            <small>诊断时间: <?php echo date('Y-m-d H:i:s T'); ?></small>
        </p>
    </div>
</body>
</html>
EOF

chown besthammer_c_usr:besthammer_c_usr public/fix-diagnosis.php
log_success "诊断页面创建完成"

log_step "第9步：验证修复结果"
echo "-----------------------------------"

# 重启Apache确保配置生效
systemctl restart apache2
sleep 3

# 测试网站访问
HTTP_STATUS_AFTER=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club" 2>/dev/null || echo "000")
log_info "修复后网站状态: HTTP $HTTP_STATUS_AFTER"

# 测试诊断页面
DIAG_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club/fix-diagnosis.php" 2>/dev/null || echo "000")
log_info "诊断页面状态: HTTP $DIAG_STATUS"

echo ""
echo "🎉 Composer修复完成！"
echo "===================="
echo ""
echo "📋 修复摘要："
echo "✅ 强制清理了损坏的vendor目录"
echo "✅ 重新安装了Composer依赖"
echo "✅ 修复了文件权限"
echo "✅ 重建了Laravel缓存"
echo "✅ 创建了诊断页面"
echo ""
echo "🧪 验证页面："
echo "   诊断页面: https://www.besthammer.club/fix-diagnosis.php"
echo "   主页测试: https://www.besthammer.club"
echo ""

if [ "$HTTP_STATUS_AFTER" = "200" ]; then
    echo "🎯 修复成功！网站现在可以正常访问。"
elif [ "$HTTP_STATUS_AFTER" = "500" ]; then
    echo "⚠️ 仍然是500错误，请访问诊断页面查看详细信息。"
else
    echo "⚠️ 网站状态: HTTP $HTTP_STATUS_AFTER，请检查诊断页面。"
fi

echo ""
echo "🔍 如果仍有问题，请："
echo "   1. 访问诊断页面查看详细错误"
echo "   2. 检查Laravel日志: storage/logs/laravel.log"
echo "   3. 检查Apache错误日志: /var/log/apache2/error.log"
echo ""
log_info "Composer修复脚本执行完成！"
