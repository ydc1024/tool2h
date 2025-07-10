#!/bin/bash

# 界面布局诊断脚本 - 分析视图样式无法恢复的原因
# 专门诊断3个主体功能模块的界面布局问题和语言转换器问题

echo "🔍 界面布局诊断脚本"
echo "=================="
echo "诊断目标："
echo "1. 分析视图样式无法恢复的根本原因"
echo "2. 检查语言转换器变成4个独立模块的问题"
echo "3. 对比true-complete-implementation.sh的原始布局"
echo "4. 检查CSS样式加载和应用情况"
echo "5. 分析Alpine.js和JavaScript交互问题"
echo "6. 检查Blade模板结构和继承关系"
echo ""

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
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

log_check() {
    echo -e "${CYAN}[CHECK]${NC} $1"
}

# 检查是否为root用户
if [ "$EUID" -ne 0 ]; then
    log_error "请使用 root 用户或 sudo 运行此脚本"
    exit 1
fi

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

if [ ! -d "$PROJECT_DIR" ]; then
    log_error "项目目录不存在: $PROJECT_DIR"
    exit 1
fi

cd "$PROJECT_DIR"

# 创建诊断报告文件
REPORT_FILE="ui_layout_diagnosis_$(date +%Y%m%d_%H%M%S).txt"
echo "界面布局诊断报告 - $(date)" > "$REPORT_FILE"
echo "==============================" >> "$REPORT_FILE"

log_step "第1步：检查主布局文件结构"
echo "-----------------------------------"

log_check "检查layouts/app.blade.php文件..."
echo "=== 主布局文件诊断 ===" >> "$REPORT_FILE"

if [ -f "resources/views/layouts/app.blade.php" ]; then
    echo "✓ 主布局文件存在" >> "$REPORT_FILE"
    log_success "主布局文件存在"
    
    # 检查关键CSS样式
    echo "检查关键CSS样式:" >> "$REPORT_FILE"
    
    if grep -q "background.*linear-gradient" resources/views/layouts/app.blade.php; then
        echo "  ✓ 渐变背景样式存在" >> "$REPORT_FILE"
        log_success "渐变背景样式存在"
    else
        echo "  ✗ 渐变背景样式缺失" >> "$REPORT_FILE"
        log_error "渐变背景样式缺失"
    fi
    
    if grep -q "backdrop-filter.*blur" resources/views/layouts/app.blade.php; then
        echo "  ✓ 毛玻璃效果样式存在" >> "$REPORT_FILE"
        log_success "毛玻璃效果样式存在"
    else
        echo "  ✗ 毛玻璃效果样式缺失" >> "$REPORT_FILE"
        log_error "毛玻璃效果样式缺失"
    fi
    
    if grep -q "\.header.*\.nav.*\.content" resources/views/layouts/app.blade.php; then
        echo "  ✓ 基础布局结构存在" >> "$REPORT_FILE"
        log_success "基础布局结构存在"
    else
        echo "  ✗ 基础布局结构缺失" >> "$REPORT_FILE"
        log_error "基础布局结构缺失"
    fi
    
    # 检查语言选择器结构
    echo "检查语言选择器结构:" >> "$REPORT_FILE"
    
    if grep -q "language-selector" resources/views/layouts/app.blade.php; then
        echo "  ✓ 语言选择器容器存在" >> "$REPORT_FILE"
        log_success "语言选择器容器存在"
        
        # 检查是否是select下拉框（原始设计）
        if grep -q "language-selector.*select" resources/views/layouts/app.blade.php; then
            echo "    ✓ 使用select下拉框（原始设计）" >> "$REPORT_FILE"
            log_success "使用select下拉框（原始设计）"
        else
            echo "    ✗ 不是select下拉框，可能被改成独立链接" >> "$REPORT_FILE"
            log_error "语言选择器不是select下拉框，可能被改成独立链接"
        fi
        
        # 检查switchLanguage函数
        if grep -q "switchLanguage" resources/views/layouts/app.blade.php; then
            echo "    ✓ switchLanguage函数存在" >> "$REPORT_FILE"
            log_success "switchLanguage函数存在"
        else
            echo "    ✗ switchLanguage函数缺失" >> "$REPORT_FILE"
            log_error "switchLanguage函数缺失"
        fi
        
    else
        echo "  ✗ 语言选择器容器缺失" >> "$REPORT_FILE"
        log_error "语言选择器容器缺失"
    fi
    
    # 检查Alpine.js引用
    if grep -q "alpinejs" resources/views/layouts/app.blade.php; then
        echo "  ✓ Alpine.js引用存在" >> "$REPORT_FILE"
        log_success "Alpine.js引用存在"
    else
        echo "  ✗ Alpine.js引用缺失" >> "$REPORT_FILE"
        log_error "Alpine.js引用缺失"
    fi
    
    # 检查CSRF令牌
    if grep -q "csrf-token" resources/views/layouts/app.blade.php; then
        echo "  ✓ CSRF令牌meta标签存在" >> "$REPORT_FILE"
        log_success "CSRF令牌meta标签存在"
    else
        echo "  ✗ CSRF令牌meta标签缺失" >> "$REPORT_FILE"
        log_error "CSRF令牌meta标签缺失"
    fi
    
else
    echo "✗ 主布局文件不存在" >> "$REPORT_FILE"
    log_error "主布局文件不存在"
fi

log_step "第2步：检查工具页面视图文件"
echo "-----------------------------------"

log_check "检查3个主体功能模块的视图文件..."
echo "=== 工具页面视图文件诊断 ===" >> "$REPORT_FILE"

tool_views=(
    "resources/views/tools/loan-calculator.blade.php"
    "resources/views/tools/bmi-calculator.blade.php"
    "resources/views/tools/currency-converter.blade.php"
)

for view_file in "${tool_views[@]}"; do
    tool_name=$(basename "$view_file" .blade.php)
    echo "检查 $tool_name:" >> "$REPORT_FILE"
    
    if [ -f "$view_file" ]; then
        echo "  ✓ 文件存在" >> "$REPORT_FILE"
        
        # 检查是否继承主布局
        if grep -q "@extends.*layouts\.app" "$view_file"; then
            echo "    ✓ 继承主布局" >> "$REPORT_FILE"
            log_success "$tool_name: 继承主布局"
        else
            echo "    ✗ 未继承主布局" >> "$REPORT_FILE"
            log_error "$tool_name: 未继承主布局"
        fi
        
        # 检查Alpine.js数据绑定
        if grep -q "x-data" "$view_file"; then
            echo "    ✓ 包含Alpine.js数据绑定" >> "$REPORT_FILE"
            log_success "$tool_name: 包含Alpine.js数据绑定"
        else
            echo "    ✗ 缺少Alpine.js数据绑定" >> "$REPORT_FILE"
            log_error "$tool_name: 缺少Alpine.js数据绑定"
        fi
        
        # 检查表单结构
        if grep -q "form.*@submit\.prevent" "$view_file"; then
            echo "    ✓ 包含Alpine.js表单处理" >> "$REPORT_FILE"
            log_success "$tool_name: 包含Alpine.js表单处理"
        else
            echo "    ✗ 缺少Alpine.js表单处理" >> "$REPORT_FILE"
            log_error "$tool_name: 缺少Alpine.js表单处理"
        fi
        
        # 检查CSS类使用
        if grep -q "calculator-form\|form-group\|result-card" "$view_file"; then
            echo "    ✓ 使用自定义CSS类" >> "$REPORT_FILE"
            log_success "$tool_name: 使用自定义CSS类"
        else
            echo "    ⚠ 可能使用Tailwind CSS而非自定义样式" >> "$REPORT_FILE"
            log_warning "$tool_name: 可能使用Tailwind CSS而非自定义样式"
        fi
        
        # 检查内联样式（可能导致样式问题）
        inline_styles=$(grep -c "style=" "$view_file" 2>/dev/null || echo "0")
        if [ "$inline_styles" -gt 10 ]; then
            echo "    ⚠ 包含过多内联样式 ($inline_styles 个)" >> "$REPORT_FILE"
            log_warning "$tool_name: 包含过多内联样式 ($inline_styles 个)"
        else
            echo "    ✓ 内联样式数量合理 ($inline_styles 个)" >> "$REPORT_FILE"
        fi
        
    else
        echo "  ✗ 文件不存在" >> "$REPORT_FILE"
        log_error "$tool_name: 文件不存在"
    fi
    echo "---" >> "$REPORT_FILE"
done

log_step "第3步：分析语言选择器问题"
echo "-----------------------------------"

log_check "深度分析语言选择器变成4个独立模块的问题..."
echo "=== 语言选择器问题分析 ===" >> "$REPORT_FILE"

# 检查当前语言选择器实现
if [ -f "resources/views/layouts/app.blade.php" ]; then
    echo "当前语言选择器实现分析:" >> "$REPORT_FILE"
    
    # 提取语言选择器相关代码
    lang_selector_code=$(grep -A 20 -B 5 "language-selector" resources/views/layouts/app.blade.php 2>/dev/null || echo "未找到")
    
    if echo "$lang_selector_code" | grep -q "<select"; then
        echo "  ✓ 当前使用select下拉框（正确的原始设计）" >> "$REPORT_FILE"
        log_success "当前使用select下拉框（正确的原始设计）"
        
        # 检查option数量
        option_count=$(echo "$lang_selector_code" | grep -c "<option" || echo "0")
        echo "    选项数量: $option_count" >> "$REPORT_FILE"
        
        if [ "$option_count" -eq 4 ]; then
            echo "    ✓ 包含4种语言选项（正确）" >> "$REPORT_FILE"
        else
            echo "    ⚠ 语言选项数量异常: $option_count" >> "$REPORT_FILE"
        fi
        
    elif echo "$lang_selector_code" | grep -q "<a.*href"; then
        echo "  ✗ 当前使用独立链接（错误实现）" >> "$REPORT_FILE"
        log_error "当前使用独立链接（错误实现）"
        
        # 计算链接数量
        link_count=$(echo "$lang_selector_code" | grep -c "<a.*href" || echo "0")
        echo "    链接数量: $link_count" >> "$REPORT_FILE"
        
        if [ "$link_count" -eq 4 ]; then
            echo "    ✗ 确认：语言选择器被改成4个独立模块" >> "$REPORT_FILE"
            log_error "确认：语言选择器被改成4个独立模块"
        fi
        
    else
        echo "  ⚠ 语言选择器实现方式不明确" >> "$REPORT_FILE"
        log_warning "语言选择器实现方式不明确"
    fi
    
    # 保存当前语言选择器代码到报告
    echo "当前语言选择器代码片段:" >> "$REPORT_FILE"
    echo "$lang_selector_code" >> "$REPORT_FILE"
    echo "---" >> "$REPORT_FILE"
fi

# 对比原始设计
echo "原始设计（true-complete-implementation.sh）:" >> "$REPORT_FILE"
echo "应该是单个select下拉框，包含:" >> "$REPORT_FILE"
echo "  - 🇺🇸 English" >> "$REPORT_FILE"
echo "  - 🇩🇪 Deutsch" >> "$REPORT_FILE"
echo "  - 🇫🇷 Français" >> "$REPORT_FILE"
echo "  - 🇪🇸 Español" >> "$REPORT_FILE"
echo "配合switchLanguage(this.value)函数进行语言切换" >> "$REPORT_FILE"

log_step "第4步：检查CSS样式冲突"
echo "-----------------------------------"

log_check "检查可能的CSS样式冲突..."
echo "=== CSS样式冲突分析 ===" >> "$REPORT_FILE"

# 检查是否同时使用了多种CSS框架
css_frameworks=()

if grep -q "tailwindcss\|tailwind" resources/views/layouts/app.blade.php; then
    css_frameworks+=("Tailwind CSS")
    echo "  发现: Tailwind CSS" >> "$REPORT_FILE"
fi

if grep -q "bootstrap" resources/views/layouts/app.blade.php; then
    css_frameworks+=("Bootstrap")
    echo "  发现: Bootstrap" >> "$REPORT_FILE"
fi

if grep -q "<style>" resources/views/layouts/app.blade.php; then
    css_frameworks+=("内联CSS")
    echo "  发现: 内联CSS样式" >> "$REPORT_FILE"
fi

if [ ${#css_frameworks[@]} -gt 1 ]; then
    echo "  ⚠ 检测到多种CSS框架可能冲突:" >> "$REPORT_FILE"
    for framework in "${css_frameworks[@]}"; do
        echo "    - $framework" >> "$REPORT_FILE"
    done
    log_warning "检测到多种CSS框架可能冲突"
else
    echo "  ✓ CSS框架使用正常" >> "$REPORT_FILE"
    log_success "CSS框架使用正常"
fi

# 检查关键样式类是否被覆盖
critical_styles=("container" "header" "nav" "content" "calculator-form" "form-group" "btn")

echo "检查关键样式类定义:" >> "$REPORT_FILE"
for style_class in "${critical_styles[@]}"; do
    if grep -q "\.$style_class\s*{" resources/views/layouts/app.blade.php; then
        echo "  ✓ .$style_class 样式已定义" >> "$REPORT_FILE"
    else
        echo "  ✗ .$style_class 样式缺失" >> "$REPORT_FILE"
        log_error "关键样式类 .$style_class 缺失"
    fi
done

log_step "第5步：检查JavaScript和Alpine.js问题"
echo "-----------------------------------"

log_check "检查JavaScript交互和Alpine.js问题..."
echo "=== JavaScript和Alpine.js诊断 ===" >> "$REPORT_FILE"

# 检查Alpine.js版本和加载
if grep -q "alpinejs@3" resources/views/layouts/app.blade.php; then
    echo "  ✓ 使用Alpine.js v3" >> "$REPORT_FILE"
    log_success "使用Alpine.js v3"
elif grep -q "alpinejs" resources/views/layouts/app.blade.php; then
    echo "  ⚠ 使用Alpine.js但版本不明确" >> "$REPORT_FILE"
    log_warning "使用Alpine.js但版本不明确"
else
    echo "  ✗ 未找到Alpine.js引用" >> "$REPORT_FILE"
    log_error "未找到Alpine.js引用"
fi

# 检查defer属性
if grep -q "defer.*alpinejs" resources/views/layouts/app.blade.php; then
    echo "  ✓ Alpine.js使用defer加载" >> "$REPORT_FILE"
    log_success "Alpine.js使用defer加载"
else
    echo "  ⚠ Alpine.js可能没有使用defer加载" >> "$REPORT_FILE"
    log_warning "Alpine.js可能没有使用defer加载"
fi

# 检查全局JavaScript配置
if grep -q "window\.Laravel" resources/views/layouts/app.blade.php; then
    echo "  ✓ Laravel全局配置存在" >> "$REPORT_FILE"
    log_success "Laravel全局配置存在"
else
    echo "  ✗ Laravel全局配置缺失" >> "$REPORT_FILE"
    log_error "Laravel全局配置缺失"
fi

# 检查工具页面的Alpine.js函数
echo "检查工具页面Alpine.js函数:" >> "$REPORT_FILE"
for view_file in "${tool_views[@]}"; do
    if [ -f "$view_file" ]; then
        tool_name=$(basename "$view_file" .blade.php)

        # 检查Alpine.js函数定义
        if grep -q "function.*Calculator\|function.*Converter" "$view_file"; then
            echo "  ✓ $tool_name: Alpine.js函数已定义" >> "$REPORT_FILE"
        else
            echo "  ✗ $tool_name: Alpine.js函数缺失" >> "$REPORT_FILE"
            log_error "$tool_name: Alpine.js函数缺失"
        fi

        # 检查AJAX请求
        if grep -q "fetch\|axios" "$view_file"; then
            echo "  ✓ $tool_name: 包含AJAX请求" >> "$REPORT_FILE"
        else
            echo "  ✗ $tool_name: 缺少AJAX请求" >> "$REPORT_FILE"
            log_error "$tool_name: 缺少AJAX请求"
        fi
    fi
done

log_step "第6步：检查路由和控制器配置"
echo "-----------------------------------"

log_check "检查路由配置和控制器方法..."
echo "=== 路由和控制器诊断 ===" >> "$REPORT_FILE"

# 检查路由文件
if [ -f "routes/web.php" ]; then
    echo "✓ 路由文件存在" >> "$REPORT_FILE"

    # 检查工具路由
    tool_routes=("tools/loan-calculator" "tools/bmi-calculator" "tools/currency-converter")

    for route in "${tool_routes[@]}"; do
        if grep -q "$route" routes/web.php; then
            echo "  ✓ $route 路由存在" >> "$REPORT_FILE"
        else
            echo "  ✗ $route 路由缺失" >> "$REPORT_FILE"
            log_error "$route 路由缺失"
        fi
    done

    # 检查多语言路由
    if grep -q "locale.*where.*en\|de\|fr\|es" routes/web.php; then
        echo "  ✓ 多语言路由配置存在" >> "$REPORT_FILE"
        log_success "多语言路由配置存在"
    else
        echo "  ✗ 多语言路由配置缺失" >> "$REPORT_FILE"
        log_error "多语言路由配置缺失"
    fi

else
    echo "✗ 路由文件不存在" >> "$REPORT_FILE"
    log_error "路由文件不存在"
fi

# 检查ToolController
if [ -f "app/Http/Controllers/ToolController.php" ]; then
    echo "✓ ToolController存在" >> "$REPORT_FILE"

    # 检查控制器方法
    controller_methods=("loanCalculator" "bmiCalculator" "currencyConverter" "localeLoanCalculator" "localeBmiCalculator" "localeCurrencyConverter")

    for method in "${controller_methods[@]}"; do
        if grep -q "function $method" app/Http/Controllers/ToolController.php; then
            echo "  ✓ $method 方法存在" >> "$REPORT_FILE"
        else
            echo "  ✗ $method 方法缺失" >> "$REPORT_FILE"
            log_error "ToolController: $method 方法缺失"
        fi
    done

else
    echo "✗ ToolController不存在" >> "$REPORT_FILE"
    log_error "ToolController不存在"
fi

log_step "第7步：生成修复建议"
echo "-----------------------------------"

echo "" >> "$REPORT_FILE"
echo "=== 问题总结和修复建议 ===" >> "$REPORT_FILE"
echo "诊断完成时间: $(date)" >> "$REPORT_FILE"

# 统计问题
echo "" >> "$REPORT_FILE"
echo "发现的主要问题:" >> "$REPORT_FILE"

# 检查关键问题
critical_issues=0

# 1. 检查主布局文件问题
if [ ! -f "resources/views/layouts/app.blade.php" ]; then
    echo "1. ❌ 主布局文件缺失" >> "$REPORT_FILE"
    ((critical_issues++))
elif ! grep -q "background.*linear-gradient" resources/views/layouts/app.blade.php; then
    echo "1. ❌ 主布局文件缺少关键CSS样式" >> "$REPORT_FILE"
    ((critical_issues++))
else
    echo "1. ✅ 主布局文件基本正常" >> "$REPORT_FILE"
fi

# 2. 检查语言选择器问题
if [ -f "resources/views/layouts/app.blade.php" ] && grep -q "language-selector.*<a.*href" resources/views/layouts/app.blade.php; then
    echo "2. ❌ 语言选择器被错误改成4个独立链接" >> "$REPORT_FILE"
    ((critical_issues++))
elif [ -f "resources/views/layouts/app.blade.php" ] && grep -q "language-selector.*select" resources/views/layouts/app.blade.php; then
    echo "2. ✅ 语言选择器使用正确的select下拉框" >> "$REPORT_FILE"
else
    echo "2. ❌ 语言选择器配置异常" >> "$REPORT_FILE"
    ((critical_issues++))
fi

# 3. 检查工具页面视图
missing_views=0
for view_file in "${tool_views[@]}"; do
    if [ ! -f "$view_file" ]; then
        ((missing_views++))
    fi
done

if [ $missing_views -gt 0 ]; then
    echo "3. ❌ $missing_views 个工具页面视图文件缺失" >> "$REPORT_FILE"
    ((critical_issues++))
else
    echo "3. ✅ 所有工具页面视图文件存在" >> "$REPORT_FILE"
fi

# 4. 检查Alpine.js配置
if [ -f "resources/views/layouts/app.blade.php" ] && ! grep -q "alpinejs" resources/views/layouts/app.blade.php; then
    echo "4. ❌ Alpine.js引用缺失" >> "$REPORT_FILE"
    ((critical_issues++))
else
    echo "4. ✅ Alpine.js配置基本正常" >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "总计发现 $critical_issues 个关键问题" >> "$REPORT_FILE"

# 生成具体修复建议
echo "" >> "$REPORT_FILE"
echo "具体修复建议:" >> "$REPORT_FILE"

if [ $critical_issues -gt 0 ]; then
    echo "" >> "$REPORT_FILE"
    echo "🔧 立即修复建议:" >> "$REPORT_FILE"
    echo "1. 运行 true-complete-implementation.sh 脚本恢复原始设计" >> "$REPORT_FILE"
    echo "2. 确保语言选择器使用select下拉框而非独立链接" >> "$REPORT_FILE"
    echo "3. 检查CSS样式是否被Tailwind CSS覆盖" >> "$REPORT_FILE"
    echo "4. 验证Alpine.js正确加载和初始化" >> "$REPORT_FILE"
    echo "5. 清理所有Laravel缓存" >> "$REPORT_FILE"

    echo "" >> "$REPORT_FILE"
    echo "🎯 根本原因分析:" >> "$REPORT_FILE"
    echo "- 可能原因1: 后续脚本覆盖了true-complete-implementation.sh的布局" >> "$REPORT_FILE"
    echo "- 可能原因2: Tailwind CSS与自定义CSS样式冲突" >> "$REPORT_FILE"
    echo "- 可能原因3: 语言选择器被错误修改为独立链接模式" >> "$REPORT_FILE"
    echo "- 可能原因4: Alpine.js版本或加载顺序问题" >> "$REPORT_FILE"
    echo "- 可能原因5: Laravel视图缓存导致旧版本显示" >> "$REPORT_FILE"

else
    echo "✅ 未发现关键问题，布局应该正常工作" >> "$REPORT_FILE"
fi

echo ""
echo "🔍 界面布局诊断完成！"
echo "===================="
echo ""
echo "📋 诊断报告已生成: $REPORT_FILE"
echo ""
echo "📊 快速诊断结果："

if [ $critical_issues -eq 0 ]; then
    echo "✅ 未发现关键问题"
    echo "   布局文件结构正常"
    echo "   语言选择器配置正确"
    echo "   Alpine.js配置正常"
else
    echo "❌ 发现 $critical_issues 个关键问题"
    echo ""
    echo "🔧 主要问题："

    if [ ! -f "resources/views/layouts/app.blade.php" ]; then
        echo "   - 主布局文件缺失"
    elif ! grep -q "background.*linear-gradient" resources/views/layouts/app.blade.php; then
        echo "   - 主布局文件缺少关键CSS样式"
    fi

    if [ -f "resources/views/layouts/app.blade.php" ] && grep -q "language-selector.*<a.*href" resources/views/layouts/app.blade.php; then
        echo "   - 语言选择器被错误改成4个独立链接"
    fi

    if [ $missing_views -gt 0 ]; then
        echo "   - $missing_views 个工具页面视图文件缺失"
    fi

    echo ""
    echo "💡 建议的修复步骤："
    echo "1. 查看完整诊断报告: cat $REPORT_FILE"
    echo "2. 运行原始布局恢复脚本: bash true-complete-implementation.sh"
    echo "3. 清理Laravel缓存: php artisan view:clear && php artisan cache:clear"
    echo "4. 重启Apache服务: systemctl restart apache2"
    echo "5. 检查浏览器开发者工具的CSS加载情况"
fi

echo ""
echo "🎯 语言选择器问题分析："
if [ -f "resources/views/layouts/app.blade.php" ]; then
    if grep -q "language-selector.*select" resources/views/layouts/app.blade.php; then
        echo "✅ 当前使用正确的select下拉框设计"
    elif grep -q "language-selector.*<a.*href" resources/views/layouts/app.blade.php; then
        echo "❌ 当前错误使用4个独立链接"
        echo "   原因：可能被后续脚本修改为链接模式"
        echo "   解决：恢复为单个select下拉框 + switchLanguage()函数"
    else
        echo "⚠️ 语言选择器配置不明确"
    fi
else
    echo "❌ 无法检查，主布局文件不存在"
fi

echo ""
log_info "界面布局诊断脚本执行完成！"
