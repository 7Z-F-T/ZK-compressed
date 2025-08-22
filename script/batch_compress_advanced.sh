#!/bin/bash

# 高级图片压缩批量处理脚本
# 用法: ./batch_compress_advanced.sh <输入目录> <输出目录> <压缩质量> [选项]

# 默认设置
APP_DIR="/usr/local/mes/files"
JAR_NAME="ZK-compressed-1.0-SNAPSHOT-jar-with-dependencies.jar"
JAR_PATH="$APP_DIR/$JAR_NAME"
DRY_RUN=false
SKIP_EXISTING=false
LOG_FILE="compression.log"

# 显示用法信息
show_usage() {
    echo "用法: $0 <输入目录> <输出目录> <压缩质量> [选项]"
    echo ""
    echo "选项:"
    echo "  -d, --dry-run     试运行，不实际处理文件"
    echo "  -s, --skip-existing 跳过已存在的输出文件"
    echo "  -l, --log <文件>   指定日志文件（默认: compression.log）"
    echo "  -h, --help        显示帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 ./photos ./compressed 0.3"
    echo "  $0 ./input ./output 0.2 --dry-run"
    echo "  $0 ./images ./compressed 0.4 --skip-existing --log mylog.txt"
}

# 解析参数
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d|--dry-run)
                DRY_RUN=true
                shift
                ;;
            -s|--skip-existing)
                SKIP_EXISTING=true
                shift
                ;;
            -l|--log)
                LOG_FILE="$2"
                shift 2
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            -*)
                echo "未知选项: $1"
                show_usage
                exit 1
                ;;
            *)
                if [ -z "$INPUT_DIR" ]; then
                    INPUT_DIR="$1"
                elif [ -z "$OUTPUT_DIR" ]; then
                    OUTPUT_DIR="$1"
                elif [ -z "$QUALITY" ]; then
                    QUALITY="$1"
                fi
                shift
                ;;
        esac
    done
}

# 初始化
initialize() {
    # 检查必要参数
    if [ -z "$INPUT_DIR" ] || [ -z "$OUTPUT_DIR" ] || [ -z "$QUALITY" ]; then
        echo "错误: 缺少必要参数"
        show_usage
        exit 1
    fi

    # 检查输入目录
    if [ ! -d "$INPUT_DIR" ]; then
        echo "错误: 输入目录 '$INPUT_DIR' 不存在"
        exit 1
    fi

    # 创建输出目录
    mkdir -p "$OUTPUT_DIR"

    # 初始化日志
    echo "=== 图片压缩批处理日志 ===" > "$LOG_FILE"
    echo "开始时间: $(date)" >> "$LOG_FILE"
    echo "输入目录: $INPUT_DIR" >> "$LOG_FILE"
    echo "输出目录: $OUTPUT_DIR" >> "$LOG_FILE"
    echo "压缩质量: $QUALITY" >> "$LOG_FILE"
    echo "模式: $([ "$DRY_RUN" = true ] && echo "试运行" || echo "实际运行")" >> "$LOG_FILE"
    echo "----------------------------------------" >> "$LOG_FILE"
}

# 主处理函数
process_files() {
    local total_files=0
    local processed_files=0
    local skipped_files=0
    local failed_files=0

    echo "开始批量处理图片..."
    echo "输入目录: $INPUT_DIR"
    echo "输出目录: $OUTPUT_DIR"
    echo "压缩质量: $QUALITY"
    echo "模式: $([ "$DRY_RUN" = true ] && echo "试运行" || echo "实际运行")"
    echo "日志文件: $LOG_FILE"
    echo "----------------------------------------"

    # 查找所有图片文件
    while IFS= read -r -d '' input_file; do
        ((total_files++))
        
        # 获取相对路径
        local relative_path="${input_file#$INPUT_DIR/}"
        local output_file="$OUTPUT_DIR/$relative_path"
        
        echo "[$total_files] 处理: $relative_path"
        echo "[$total_files] 处理: $relative_path" >> "$LOG_FILE"

        # 检查是否跳过已存在文件
        if [ "$SKIP_EXISTING" = true ] && [ -f "$output_file" ]; then
            echo "  跳过: 输出文件已存在"
            echo "  跳过: 输出文件已存在" >> "$LOG_FILE"
            ((skipped_files++))
            continue
        fi

        # 创建输出目录
        mkdir -p "$(dirname "$output_file")"

        # 获取文件扩展名并转为小写
        local extension="${input_file##*.}"
        local lower_extension="${extension,,}"

        # 判断文件类型
        if [[ "$lower_extension" == "jpg" || "$lower_extension" == "jpeg" ]]; then
            # 对于 JPG/JPEG 文件，执行压缩
            echo "  类型: JPEG/JPG, 执行压缩" >> "$LOG_FILE"
            if [ "$DRY_RUN" = true ]; then
                echo "  试运行: 将压缩 $input_file → $output_file"
                echo "  试运行: 将压缩 $input_file → $output_file" >> "$LOG_FILE"
                ((processed_files++))
            else
                if nohup java -jar "$JAR_PATH" "$input_file" "$output_file" "$QUALITY" >> "$LOG_FILE" 2>&1 & then
                    # 计算压缩率
                    local original_size=$(stat -c%s "$input_file" 2>/dev/null || stat -f%z "$input_file" 2>/dev/null)
                    local compressed_size=$(stat -c%s "$output_file" 2>/dev/null || stat -f%z "$output_file" 2>/dev/null)
                    if [[ -n "$original_size" && "$original_size" -gt 0 && -n "$compressed_size" ]]; then
                        local compression_ratio=$(echo "scale=2; (1 - $compressed_size / $original_size) * 100" | bc)
                        echo "  ✓ 成功: 压缩率 ${compression_ratio}%"
                        echo "  ✓ 成功: 压缩率 ${compression_ratio}%" >> "$LOG_FILE"
                    else
                        echo "  ✓ 成功: 已压缩 (无法计算压缩率)"
                        echo "  ✓ 成功: 已压缩 (无法计算压缩率)" >> "$LOG_FILE"
                    fi
                    ((processed_files++))
                else
                    echo "  ✗ 失败: 压缩过程中出现错误"
                    echo "  ✗ 失败: 压缩过程中出现错误" >> "$LOG_FILE"
                    ((failed_files++))
                fi
            fi
        else
            # 对于其他格式的文件，直接复制
            echo "  类型: $extension, 直接复制" >> "$LOG_FILE"
            if [ "$DRY_RUN" = true ]; then
                echo "  试运行: 将复制 $input_file → $output_file"
                echo "  试运行: 将复制 $input_file → $output_file" >> "$LOG_FILE"
                ((processed_files++))
            else
                if cp "$input_file" "$output_file"; then
                    echo "  ✓ 成功: 文件已复制"
                    echo "  ✓ 成功: 文件已复制" >> "$LOG_FILE"
                    ((processed_files++))
                else
                    echo "  ✗ 失败: 复制过程中出现错误"
                    echo "  ✗ 失败: 复制过程中出现错误" >> "$LOG_FILE"
                    ((failed_files++))
                fi
            fi
        fi
        
        echo "----------------------------------------" >> "$LOG_FILE"
    done < <(find "$INPUT_DIR" -type f \(\
        -iname "*.jpg" -o \
        -iname "*.jpeg" -o \
        -iname "*.png" -o \
        -iname "*.bmp" -o \
        -iname "*.tiff" -o \
        -iname "*.tif" -o \
        -iname "*.webp" \
    \) -print0)

    # 输出统计信息
    echo "处理完成!"
    echo "========================================"
    echo "总共找到文件: $total_files"
    echo "成功处理文件: $processed_files"
    echo "跳过文件: $skipped_files"
    echo "失败文件: $failed_files"
    echo "详细日志请查看: $LOG_FILE"

    # 记录到日志
    echo "=======================================" >> "$LOG_FILE"
    echo "结束时间: $(date)" >> "$LOG_FILE"
    echo "总共找到文件: $total_files" >> "$LOG_FILE"
    echo "成功处理文件: $processed_files" >> "$LOG_FILE"
    echo "跳过文件: $skipped_files" >> "$LOG_FILE"
    echo "失败文件: $failed_files" >> "$LOG_FILE"
}


# 主程序
main() {
    parse_arguments "$@"
    initialize
    process_files
}

# 运行主程序
main "$@"
