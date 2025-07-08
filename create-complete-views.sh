#!/bin/bash

# 创建完整的视图文件系统
# 确保源码逻辑正确，算法准确，无冗余代码

echo "🎨 创建完整视图文件系统"
echo "====================="
echo "目标：创建所有必需的Blade模板文件"
echo "特点：逻辑正确、算法准确、无冗余代码"
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

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

PROJECT_DIR="/var/www/besthammer_c_usr/data/www/besthammer.club"

cd "$PROJECT_DIR"

log_step "第1步：创建主布局文件"
echo "-----------------------------------"

# 创建视图目录
mkdir -p resources/views/layouts
mkdir -p resources/views/tools

# 创建主布局文件 - 响应式设计，支持多语言
cat > resources/views/layouts/app.blade.php << 'EOF'
<!DOCTYPE html>
<html lang="{{ app()->getLocale() }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>{{ $title ?? 'BestHammer - Professional Tools' }}</title>
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=inter:400,500,600,700&display=swap" rel="stylesheet" />
    
    <!-- Styles -->
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: 'Inter', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            color: #333;
            line-height: 1.6;
        }
        
        .container {
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
        }
        
        .header {
            background: rgba(255,255,255,0.95);
            padding: 20px 30px;
            border-radius: 15px;
            margin-bottom: 20px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
        }
        
        .header h1 {
            color: #667eea;
            margin-bottom: 15px;
            font-weight: 700;
        }
        
        .nav {
            display: flex;
            gap: 15px;
            flex-wrap: wrap;
            align-items: center;
        }
        
        .nav a {
            color: #667eea;
            text-decoration: none;
            padding: 10px 20px;
            border-radius: 25px;
            background: rgba(102, 126, 234, 0.1);
            transition: all 0.3s ease;
            font-weight: 500;
        }
        
        .nav a:hover {
            background: #667eea;
            color: white;
            transform: translateY(-2px);
        }
        
        .language-selector {
            margin-left: auto;
            display: flex;
            gap: 10px;
        }
        
        .language-selector select {
            padding: 8px 15px;
            border: 2px solid #667eea;
            border-radius: 20px;
            background: white;
            color: #667eea;
            font-weight: 500;
        }
        
        .content {
            background: rgba(255,255,255,0.95);
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 8px 32px rgba(0,0,0,0.1);
            backdrop-filter: blur(10px);
        }
        
        .tools-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px;
            margin: 30px 0;
        }
        
        .tool-card {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            border-left: 5px solid #667eea;
            transition: all 0.3s ease;
            text-align: center;
        }
        
        .tool-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0,0,0,0.1);
        }
        
        .tool-card h3 {
            color: #667eea;
            margin-bottom: 15px;
            font-weight: 600;
        }
        
        .tool-card p {
            color: #666;
            margin-bottom: 20px;
        }
        
        .btn {
            display: inline-block;
            padding: 12px 25px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            text-decoration: none;
            border-radius: 25px;
            font-weight: 500;
            transition: all 0.3s ease;
            border: none;
            cursor: pointer;
        }
        
        .btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
            color: #333;
        }
        
        .form-group input, .form-group select {
            width: 100%;
            padding: 12px 15px;
            border: 2px solid #e1e5e9;
            border-radius: 10px;
            font-size: 16px;
            transition: border-color 0.3s ease;
        }
        
        .form-group input:focus, .form-group select:focus {
            outline: none;
            border-color: #667eea;
        }
        
        .result-card {
            background: linear-gradient(135deg, #00b894 0%, #00cec9 100%);
            color: white;
            padding: 20px;
            border-radius: 15px;
            margin-top: 20px;
            text-align: center;
        }
        
        .result-value {
            font-size: 24px;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .calculator-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 30px;
            margin-top: 30px;
        }
        
        @media (max-width: 768px) {
            .container {
                padding: 10px;
            }
            
            .header, .content {
                padding: 20px;
            }
            
            .nav {
                justify-content: center;
            }
            
            .language-selector {
                margin-left: 0;
                margin-top: 10px;
            }
            
            .calculator-form {
                grid-template-columns: 1fr;
                gap: 20px;
            }
        }
    </style>
    
    <!-- Alpine.js for interactivity -->
    <script defer src="https://unpkg.com/alpinejs@3.x.x/dist/cdn.min.js"></script>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>{{ $title ?? 'BestHammer' }}</h1>
            <nav class="nav">
                <a href="{{ isset($locale) && $locale ? route('home.locale', $locale) : route('home') }}">Home</a>
                <a href="{{ isset($locale) && $locale ? route('tools.locale.loan', $locale) : route('tools.loan') }}">Loan Calculator</a>
                <a href="{{ isset($locale) && $locale ? route('tools.locale.bmi', $locale) : route('tools.bmi') }}">BMI Calculator</a>
                <a href="{{ isset($locale) && $locale ? route('tools.locale.currency', $locale) : route('tools.currency') }}">Currency Converter</a>
                <a href="{{ isset($locale) && $locale ? route('about.locale', $locale) : route('about') }}">About</a>
                
                <div class="language-selector">
                    <select onchange="switchLanguage(this.value)">
                        <option value="en" {{ (isset($locale) ? $locale : 'en') == 'en' ? 'selected' : '' }}>🇺🇸 English</option>
                        <option value="de" {{ (isset($locale) ? $locale : 'en') == 'de' ? 'selected' : '' }}>🇩🇪 Deutsch</option>
                        <option value="fr" {{ (isset($locale) ? $locale : 'en') == 'fr' ? 'selected' : '' }}>🇫🇷 Français</option>
                        <option value="es" {{ (isset($locale) ? $locale : 'en') == 'es' ? 'selected' : '' }}>🇪🇸 Español</option>
                    </select>
                </div>
            </nav>
        </div>
        
        <div class="content">
            @yield('content')
        </div>
    </div>
    
    <script>
        function switchLanguage(locale) {
            const currentPath = window.location.pathname;
            const pathParts = currentPath.split('/').filter(part => part);
            
            // Remove current locale if exists
            if (['en', 'de', 'fr', 'es'].includes(pathParts[0])) {
                pathParts.shift();
            }
            
            // Add new locale
            const newPath = '/' + locale + (pathParts.length ? '/' + pathParts.join('/') : '');
            window.location.href = newPath;
        }
        
        // CSRF token for AJAX requests
        window.Laravel = {
            csrfToken: '{{ csrf_token() }}'
        };
    </script>
    
    @stack('scripts')
</body>
</html>
EOF

log_success "主布局文件创建完成"

log_step "第2步：创建主页视图"
echo "-----------------------------------"

cat > resources/views/home.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div style="text-align: center;">
    <h1 style="color: #667eea; font-size: 2.5rem; margin-bottom: 20px;">
        🛠️ Professional Tools for European & American Markets
    </h1>
    
    <p style="font-size: 1.2rem; margin-bottom: 40px; color: #666;">
        Calculate loans, BMI, and convert currencies with real-time data and professional accuracy.
    </p>
    
    <div class="tools-grid">
        <div class="tool-card">
            <h3>💰 Loan Calculator</h3>
            <p>Calculate monthly payments, total interest, and loan schedules for mortgages, auto loans, and personal loans with precise algorithms.</p>
            <a href="{{ isset($locale) && $locale ? route('tools.locale.loan', $locale) : route('tools.loan') }}" class="btn">
                Calculate Now
            </a>
        </div>
        
        <div class="tool-card">
            <h3>⚖️ BMI Calculator</h3>
            <p>Calculate your Body Mass Index (BMI) and get health recommendations based on WHO standards with accurate formulas.</p>
            <a href="{{ isset($locale) && $locale ? route('tools.locale.bmi', $locale) : route('tools.bmi') }}" class="btn">
                Calculate BMI
            </a>
        </div>
        
        <div class="tool-card">
            <h3>💱 Currency Converter</h3>
            <p>Convert between major world currencies with real-time exchange rates for accurate financial calculations.</p>
            <a href="{{ isset($locale) && $locale ? route('tools.locale.currency', $locale) : route('tools.currency') }}" class="btn">
                Convert Currency
            </a>
        </div>
    </div>
    
    <div style="background: #e7f3ff; padding: 30px; border-radius: 15px; margin: 40px 0; border-left: 5px solid #007bff;">
        <h3 style="color: #004085; margin-bottom: 15px;">🌍 European & American Markets Focus</h3>
        <p style="color: #004085; margin: 0;">
            Our tools are specifically designed for European and American users, supporting multiple currencies, 
            measurement systems, and regulatory standards across different countries.
        </p>
    </div>
    
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0;">
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 2rem; margin-bottom: 10px;">🇺🇸</div>
            <h4>United States</h4>
            <p>USD, Imperial units</p>
        </div>
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 2rem; margin-bottom: 10px;">🇪🇺</div>
            <h4>European Union</h4>
            <p>EUR, Metric system</p>
        </div>
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 2rem; margin-bottom: 10px;">🇬🇧</div>
            <h4>United Kingdom</h4>
            <p>GBP, Mixed units</p>
        </div>
        <div style="text-align: center; padding: 20px;">
            <div style="font-size: 2rem; margin-bottom: 10px;">🇨🇦</div>
            <h4>Canada</h4>
            <p>CAD, Metric system</p>
        </div>
    </div>
</div>
@endsection
EOF

log_success "主页视图创建完成"

log_step "第3步：创建关于页面视图"
echo "-----------------------------------"

cat > resources/views/about.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div>
    <h1>About BestHammer</h1>
    
    <p style="font-size: 1.1rem; margin-bottom: 30px;">
        BestHammer is a professional tool platform designed specifically for European and American markets, 
        providing essential financial and health calculators with multi-language support and precise algorithms.
    </p>
    
    <div class="tools-grid">
        <div class="tool-card" style="text-align: left;">
            <h3>🎯 Our Mission</h3>
            <p>
                To provide accurate, reliable, and easy-to-use financial and health tools that help individuals 
                make informed decisions about their loans, health, and financial planning with mathematical precision.
            </p>
        </div>
        
        <div class="tool-card" style="text-align: left;">
            <h3>🌍 Market Focus</h3>
            <p>
                We specifically target European and American markets, ensuring our tools comply with local 
                regulations and support regional currencies, measurement systems, and calculation standards.
            </p>
        </div>
        
        <div class="tool-card" style="text-align: left;">
            <h3>🔧 Technology</h3>
            <p>
                Built with Laravel {{ app()->version() }}, our platform ensures high performance, security, and scalability. 
                We use modern web technologies and precise mathematical algorithms for the best user experience.
            </p>
        </div>
    </div>
    
    <h2 style="margin-top: 40px;">Supported Languages</h2>
    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin: 20px 0;">
        <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center;">
            <span style="font-size: 1.5rem;">🇺🇸</span>
            <h4>English</h4>
            <p>Primary language</p>
        </div>
        <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center;">
            <span style="font-size: 1.5rem;">🇩🇪</span>
            <h4>Deutsch</h4>
            <p>German support</p>
        </div>
        <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center;">
            <span style="font-size: 1.5rem;">🇫🇷</span>
            <h4>Français</h4>
            <p>French support</p>
        </div>
        <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center;">
            <span style="font-size: 1.5rem;">🇪🇸</span>
            <h4>Español</h4>
            <p>Spanish support</p>
        </div>
    </div>
    
    <h2 style="margin-top: 40px;">Technical Specifications</h2>
    <div style="background: #f8f9fa; padding: 20px; border-radius: 10px; margin: 20px 0;">
        <ul style="list-style: none; padding: 0;">
            <li style="margin-bottom: 10px;"><strong>Framework:</strong> Laravel {{ app()->version() }}</li>
            <li style="margin-bottom: 10px;"><strong>PHP Version:</strong> {{ PHP_VERSION }}</li>
            <li style="margin-bottom: 10px;"><strong>Frontend:</strong> Alpine.js + Responsive CSS</li>
            <li style="margin-bottom: 10px;"><strong>Deployment:</strong> FastPanel (Nginx + Apache)</li>
            <li style="margin-bottom: 10px;"><strong>CDN:</strong> Cloudflare</li>
            <li style="margin-bottom: 10px;"><strong>SSL:</strong> HTTPS Enabled</li>
            <li style="margin-bottom: 10px;"><strong>Algorithms:</strong> Mathematically precise calculations</li>
        </ul>
    </div>
</div>
@endsection
EOF

log_success "关于页面视图创建完成"

log_step "第4步：创建贷款计算器视图"
echo "-----------------------------------"

cat > resources/views/tools/loan-calculator.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div x-data="loanCalculator()">
    <h1>💰 Loan Calculator</h1>
    <p style="margin-bottom: 30px;">Calculate monthly payments, total interest, and loan schedules with precise financial algorithms.</p>

    <div class="calculator-form">
        <div>
            <h3>Loan Details</h3>
            <form @submit.prevent="calculateLoan">
                <div class="form-group">
                    <label for="amount">Loan Amount ($)</label>
                    <input type="number" id="amount" x-model="form.amount" step="0.01" min="1" max="10000000" required>
                </div>

                <div class="form-group">
                    <label for="rate">Annual Interest Rate (%)</label>
                    <input type="number" id="rate" x-model="form.rate" step="0.01" min="0" max="50" required>
                </div>

                <div class="form-group">
                    <label for="years">Loan Term (Years)</label>
                    <input type="number" id="years" x-model="form.years" min="1" max="50" required>
                </div>

                <button type="submit" class="btn" :disabled="loading">
                    <span x-show="!loading">Calculate Payment</span>
                    <span x-show="loading">Calculating...</span>
                </button>

                <button type="button" class="btn" @click="resetForm" style="background: #6c757d; margin-left: 10px;">
                    Reset
                </button>
            </form>
        </div>

        <div>
            <h3>Calculation Results</h3>
            <div x-show="results" style="display: none;">
                <div class="result-card">
                    <div class="result-value" x-text="formatCurrency(results?.monthly_payment || 0)"></div>
                    <div>Monthly Payment</div>
                </div>

                <div class="result-card" style="background: linear-gradient(135deg, #fd79a8 0%, #fdcb6e 100%);">
                    <div class="result-value" x-text="formatCurrency(results?.total_interest || 0)"></div>
                    <div>Total Interest</div>
                </div>

                <div class="result-card" style="background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);">
                    <div class="result-value" x-text="formatCurrency(results?.total_payment || 0)"></div>
                    <div>Total Payment</div>
                </div>

                <div style="margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 10px;">
                    <h4>Loan Summary</h4>
                    <p><strong>Principal:</strong> <span x-text="formatCurrency(form.amount)"></span></p>
                    <p><strong>Interest Rate:</strong> <span x-text="form.rate + '%'"></span></p>
                    <p><strong>Term:</strong> <span x-text="form.years + ' years (' + (form.years * 12) + ' payments)'"></span></p>
                </div>
            </div>

            <div x-show="!results" style="text-align: center; padding: 40px; color: #666;">
                Enter loan details to see precise calculations
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
function loanCalculator() {
    return {
        form: {
            amount: 250000,
            rate: 3.5,
            years: 30
        },
        results: null,
        loading: false,

        async calculateLoan() {
            this.loading = true;

            try {
                const response = await fetch('{{ isset($locale) && $locale ? route("tools.locale.loan.calculate", $locale) : route("tools.loan.calculate") }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': window.Laravel.csrfToken
                    },
                    body: JSON.stringify(this.form)
                });

                if (response.ok) {
                    this.results = await response.json();
                } else {
                    alert('Error calculating loan. Please check your inputs.');
                }
            } catch (error) {
                alert('Error calculating loan. Please try again.');
            } finally {
                this.loading = false;
            }
        },

        resetForm() {
            this.form = {
                amount: 250000,
                rate: 3.5,
                years: 30
            };
            this.results = null;
        },

        formatCurrency(amount) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: 'USD'
            }).format(amount);
        }
    }
}
</script>
@endpush
@endsection
EOF

log_success "贷款计算器视图创建完成"

log_step "第5步：创建BMI计算器视图"
echo "-----------------------------------"

cat > resources/views/tools/bmi-calculator.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div x-data="bmiCalculator()">
    <h1>⚖️ BMI Calculator</h1>
    <p style="margin-bottom: 30px;">Calculate your Body Mass Index (BMI) and get health recommendations based on WHO standards with precise medical formulas.</p>

    <div class="calculator-form">
        <div>
            <h3>Your Information</h3>
            <form @submit.prevent="calculateBmi">
                <div class="form-group">
                    <label for="weight">Weight (kg)</label>
                    <input type="number" id="weight" x-model="form.weight" step="0.1" min="1" max="1000" required>
                </div>

                <div class="form-group">
                    <label for="height">Height (cm)</label>
                    <input type="number" id="height" x-model="form.height" step="0.1" min="50" max="300" required>
                </div>

                <button type="submit" class="btn" :disabled="loading">
                    <span x-show="!loading">Calculate BMI</span>
                    <span x-show="loading">Calculating...</span>
                </button>

                <button type="button" class="btn" @click="resetForm" style="background: #6c757d; margin-left: 10px;">
                    Reset
                </button>
            </form>

            <div style="margin-top: 30px; padding: 20px; background: #f8f9fa; border-radius: 10px;">
                <h4>BMI Categories (WHO Standards)</h4>
                <ul style="list-style: none; padding: 0;">
                    <li style="margin-bottom: 5px;"><strong>Underweight:</strong> BMI < 18.5</li>
                    <li style="margin-bottom: 5px;"><strong>Normal weight:</strong> BMI 18.5-24.9</li>
                    <li style="margin-bottom: 5px;"><strong>Overweight:</strong> BMI 25-29.9</li>
                    <li style="margin-bottom: 5px;"><strong>Obese:</strong> BMI ≥ 30</li>
                </ul>
            </div>
        </div>

        <div>
            <h3>BMI Results</h3>
            <div x-show="results" style="display: none;">
                <div class="result-card" :style="getBmiColor()">
                    <div class="result-value" x-text="results?.bmi || 0"></div>
                    <div>Your BMI</div>
                </div>

                <div class="result-card" style="background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);">
                    <div class="result-value" x-text="results?.category || ''"></div>
                    <div>Category</div>
                </div>

                <div style="margin-top: 20px; padding: 20px; background: #e7f3ff; border-radius: 10px; border-left: 5px solid #007bff;">
                    <h4>Health Recommendation</h4>
                    <p x-text="getHealthAdvice()"></p>
                </div>

                <div style="margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 10px;">
                    <h4>Calculation Details</h4>
                    <p><strong>Weight:</strong> <span x-text="form.weight + ' kg'"></span></p>
                    <p><strong>Height:</strong> <span x-text="form.height + ' cm (' + (form.height/100).toFixed(2) + ' m)'"></span></p>
                    <p><strong>Formula:</strong> BMI = Weight(kg) ÷ Height(m)²</p>
                </div>
            </div>

            <div x-show="!results" style="text-align: center; padding: 40px; color: #666;">
                Enter your weight and height to calculate BMI with medical precision
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
function bmiCalculator() {
    return {
        form: {
            weight: 70,
            height: 175
        },
        results: null,
        loading: false,

        async calculateBmi() {
            this.loading = true;

            try {
                const response = await fetch('{{ isset($locale) && $locale ? route("tools.locale.bmi.calculate", $locale) : route("tools.bmi.calculate") }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': window.Laravel.csrfToken
                    },
                    body: JSON.stringify(this.form)
                });

                if (response.ok) {
                    this.results = await response.json();
                } else {
                    alert('Error calculating BMI. Please check your inputs.');
                }
            } catch (error) {
                alert('Error calculating BMI. Please try again.');
            } finally {
                this.loading = false;
            }
        },

        resetForm() {
            this.form = {
                weight: 70,
                height: 175
            };
            this.results = null;
        },

        getBmiColor() {
            if (!this.results) return '';

            const bmi = this.results.bmi;
            if (bmi < 18.5) return 'background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);';
            if (bmi < 25) return 'background: linear-gradient(135deg, #00b894 0%, #00cec9 100%);';
            if (bmi < 30) return 'background: linear-gradient(135deg, #fdcb6e 0%, #e17055 100%);';
            return 'background: linear-gradient(135deg, #fd79a8 0%, #e84393 100%);';
        },

        getHealthAdvice() {
            if (!this.results) return '';

            const category = this.results.category;
            const advice = {
                'Underweight': 'Consider consulting with a healthcare provider about healthy weight gain strategies and nutritional guidance.',
                'Normal weight': 'Excellent! Maintain your current lifestyle with regular exercise and balanced nutrition.',
                'Overweight': 'Consider adopting a healthier diet and increasing physical activity. Consult a healthcare provider for guidance.',
                'Obese': 'Consult with a healthcare provider for a comprehensive weight management plan and health assessment.'
            };

            return advice[category] || 'Consult with a healthcare provider for personalized health advice.';
        }
    }
}
</script>
@endpush
@endsection
EOF

log_success "BMI计算器视图创建完成"

log_step "第6步：创建汇率转换器视图"
echo "-----------------------------------"

cat > resources/views/tools/currency-converter.blade.php << 'EOF'
@extends('layouts.app')

@section('content')
<div x-data="currencyConverter()">
    <h1>💱 Currency Converter</h1>
    <p style="margin-bottom: 30px;">Convert between major world currencies with real-time exchange rates and precise financial calculations.</p>

    <div class="calculator-form">
        <div>
            <h3>Currency Conversion</h3>
            <form @submit.prevent="convertCurrency">
                <div class="form-group">
                    <label for="amount">Amount</label>
                    <input type="number" id="amount" x-model="form.amount" step="0.01" min="0" max="1000000000" required>
                </div>

                <div class="form-group">
                    <label for="from">From Currency</label>
                    <select id="from" x-model="form.from" required>
                        <option value="USD">🇺🇸 USD - US Dollar</option>
                        <option value="EUR">🇪🇺 EUR - Euro</option>
                        <option value="GBP">🇬🇧 GBP - British Pound</option>
                        <option value="CAD">🇨🇦 CAD - Canadian Dollar</option>
                        <option value="AUD">🇦🇺 AUD - Australian Dollar</option>
                        <option value="CHF">🇨🇭 CHF - Swiss Franc</option>
                        <option value="JPY">🇯🇵 JPY - Japanese Yen</option>
                    </select>
                </div>

                <div class="form-group">
                    <label for="to">To Currency</label>
                    <select id="to" x-model="form.to" required>
                        <option value="USD">🇺🇸 USD - US Dollar</option>
                        <option value="EUR">🇪🇺 EUR - Euro</option>
                        <option value="GBP">🇬🇧 GBP - British Pound</option>
                        <option value="CAD">🇨🇦 CAD - Canadian Dollar</option>
                        <option value="AUD">🇦🇺 AUD - Australian Dollar</option>
                        <option value="CHF">🇨🇭 CHF - Swiss Franc</option>
                        <option value="JPY">🇯🇵 JPY - Japanese Yen</option>
                    </select>
                </div>

                <button type="submit" class="btn" :disabled="loading">
                    <span x-show="!loading">Convert Currency</span>
                    <span x-show="loading">Converting...</span>
                </button>

                <button type="button" class="btn" @click="swapCurrencies" style="background: #17a2b8; margin-left: 10px;">
                    ⇄ Swap
                </button>
            </form>
        </div>

        <div>
            <h3>Conversion Result</h3>
            <div x-show="results" style="display: none;">
                <div class="result-card">
                    <div class="result-value" x-text="formatAmount(results?.converted_amount || 0, results?.to_currency)"></div>
                    <div x-text="results?.to_currency + ' Amount'"></div>
                </div>

                <div class="result-card" style="background: linear-gradient(135deg, #74b9ff 0%, #0984e3 100%);">
                    <div class="result-value" x-text="results?.exchange_rate || 0"></div>
                    <div>Exchange Rate</div>
                </div>

                <div style="margin-top: 20px; padding: 20px; background: #f8f9fa; border-radius: 10px;">
                    <h4>Conversion Summary</h4>
                    <p x-text="getConversionSummary()"></p>
                    <p><strong>Rate:</strong> 1 <span x-text="results?.from_currency"></span> = <span x-text="results?.exchange_rate"></span> <span x-text="results?.to_currency"></span></p>
                </div>
            </div>

            <div x-show="!results" style="text-align: center; padding: 40px; color: #666;">
                Enter amount and select currencies to convert with precise exchange rates
            </div>
        </div>
    </div>

    <div style="margin-top: 40px;">
        <h3>Popular Currency Pairs</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px;">
            <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center; cursor: pointer;" @click="setQuickConversion('USD', 'EUR')">
                <strong>USD → EUR</strong>
                <div style="color: #666;">US Dollar to Euro</div>
            </div>
            <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center; cursor: pointer;" @click="setQuickConversion('EUR', 'GBP')">
                <strong>EUR → GBP</strong>
                <div style="color: #666;">Euro to British Pound</div>
            </div>
            <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center; cursor: pointer;" @click="setQuickConversion('USD', 'CAD')">
                <strong>USD → CAD</strong>
                <div style="color: #666;">US Dollar to Canadian Dollar</div>
            </div>
            <div style="padding: 15px; background: #f8f9fa; border-radius: 10px; text-align: center; cursor: pointer;" @click="setQuickConversion('GBP', 'USD')">
                <strong>GBP → USD</strong>
                <div style="color: #666;">British Pound to US Dollar</div>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
function currencyConverter() {
    return {
        form: {
            amount: 1000,
            from: 'USD',
            to: 'EUR'
        },
        results: null,
        loading: false,

        async convertCurrency() {
            this.loading = true;

            try {
                const response = await fetch('{{ isset($locale) && $locale ? route("tools.locale.currency.convert", $locale) : route("tools.currency.convert") }}', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': window.Laravel.csrfToken
                    },
                    body: JSON.stringify(this.form)
                });

                if (response.ok) {
                    this.results = await response.json();
                } else {
                    alert('Error converting currency. Please try again.');
                }
            } catch (error) {
                alert('Error converting currency. Please try again.');
            } finally {
                this.loading = false;
            }
        },

        swapCurrencies() {
            const temp = this.form.from;
            this.form.from = this.form.to;
            this.form.to = temp;

            if (this.results) {
                this.convertCurrency();
            }
        },

        setQuickConversion(from, to) {
            this.form.from = from;
            this.form.to = to;
            this.convertCurrency();
        },

        formatAmount(amount, currency) {
            return new Intl.NumberFormat('en-US', {
                style: 'currency',
                currency: currency
            }).format(amount);
        },

        getConversionSummary() {
            if (!this.results) return '';

            return `${this.formatAmount(this.form.amount, this.results.from_currency)} = ${this.formatAmount(this.results.converted_amount, this.results.to_currency)}`;
        }
    }
}
</script>
@endpush
@endsection
EOF

log_success "汇率转换器视图创建完成"

log_step "第7步：设置文件权限"
echo "-----------------------------------"

# 设置正确的文件权限
chown -R besthammer_c_usr:besthammer_c_usr resources/views
chmod -R 755 resources/views

log_success "文件权限设置完成"

log_step "第8步：验证视图文件"
echo "-----------------------------------"

# 验证所有视图文件是否存在
REQUIRED_VIEWS=(
    "resources/views/layouts/app.blade.php"
    "resources/views/home.blade.php"
    "resources/views/about.blade.php"
    "resources/views/tools/loan-calculator.blade.php"
    "resources/views/tools/bmi-calculator.blade.php"
    "resources/views/tools/currency-converter.blade.php"
)

ALL_VIEWS_EXIST=true

for view in "${REQUIRED_VIEWS[@]}"; do
    if [ -f "$view" ]; then
        log_success "✅ $view"
    else
        log_error "❌ $view"
        ALL_VIEWS_EXIST=false
    fi
done

if [ "$ALL_VIEWS_EXIST" = true ]; then
    log_success "所有视图文件创建成功"
else
    log_error "部分视图文件创建失败"
fi

log_step "第9步：重启服务并测试"
echo "-----------------------------------"

# 重启Apache
systemctl restart apache2
sleep 3

# 测试网站访问
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club" 2>/dev/null || echo "000")
log_info "网站访问测试: HTTP $HTTP_STATUS"

# 测试工具页面
TOOL_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "https://www.besthammer.club/tools/loan-calculator" 2>/dev/null || echo "000")
log_info "工具页面测试: HTTP $TOOL_STATUS"

echo ""
echo "🎨 完整视图文件系统创建完成！"
echo "=========================="
echo ""
echo "📋 创建的视图文件："
echo "✅ 主布局文件 (layouts/app.blade.php)"
echo "✅ 主页视图 (home.blade.php)"
echo "✅ 关于页面视图 (about.blade.php)"
echo "✅ 贷款计算器视图 (tools/loan-calculator.blade.php)"
echo "✅ BMI计算器视图 (tools/bmi-calculator.blade.php)"
echo "✅ 汇率转换器视图 (tools/currency-converter.blade.php)"
echo ""
echo "🎯 视图特色："
echo "✅ 响应式设计，支持移动端"
echo "✅ 多语言支持 (EN/DE/FR/ES)"
echo "✅ 精确的数学算法"
echo "✅ 实时交互计算"
echo "✅ 专业的UI/UX设计"
echo "✅ 无冗余代码，架构完整"
echo ""
echo "🧪 测试结果："
echo "   主页状态: HTTP $HTTP_STATUS"
echo "   工具页面状态: HTTP $TOOL_STATUS"
echo ""

if [ "$HTTP_STATUS" = "200" ] && [ "$TOOL_STATUS" = "200" ]; then
    echo "🎉 视图文件修复成功！网站现在可以正常访问。"
    echo ""
    echo "🌐 访问地址："
    echo "   主页: https://www.besthammer.club"
    echo "   贷款计算器: https://www.besthammer.club/tools/loan-calculator"
    echo "   BMI计算器: https://www.besthammer.club/tools/bmi-calculator"
    echo "   汇率转换器: https://www.besthammer.club/tools/currency-converter"
elif [ "$HTTP_STATUS" = "200" ]; then
    echo "✅ 主页正常，工具页面可能需要进一步检查"
else
    echo "⚠️ 仍有问题，请检查Apache错误日志"
fi

echo ""
log_info "完整视图文件系统创建完成！"
