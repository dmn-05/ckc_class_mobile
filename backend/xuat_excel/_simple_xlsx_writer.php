<?php

declare(strict_types=1);

/**
 * Trình ghi XLSX tối giản cho CKC Class.
 *
 * Lưu ý quan trọng:
 * - XLSX là gói ZIP chứa các tệp XML theo đúng thứ tự phần tử OOXML.
 * - autoFilter phải được ghi trước mergeCells trong worksheet.
 * - Mọi chuỗi phải được làm sạch ký tự không hợp lệ của XML 1.0.
 */
final class SimpleXlsxWriter
{
    private static function xml(string $value): string
    {
        // Chuẩn hóa chuỗi UTF-8 nếu mbstring có sẵn.
        if (function_exists('mb_convert_encoding')) {
            $value = mb_convert_encoding($value, 'UTF-8', 'UTF-8');
        }

        // Loại bỏ các ký tự điều khiển không được XML 1.0 cho phép.
        // Giữ TAB (09), LF (0A), CR (0D) và các vùng ký tự Unicode hợp lệ.
        $cleaned = preg_replace(
            '/[^\x{0009}\x{000A}\x{000D}\x{0020}-\x{D7FF}\x{E000}-\x{FFFD}\x{10000}-\x{10FFFF}]/u',
            '',
            $value
        );

        if ($cleaned === null) {
            $cleaned = '';
        }

        return htmlspecialchars(
            $cleaned,
            ENT_XML1 | ENT_QUOTES | ENT_SUBSTITUTE,
            'UTF-8'
        );
    }

    private static function columnName(int $index): string
    {
        if ($index <= 0) {
            throw new InvalidArgumentException('Chỉ số cột Excel phải lớn hơn 0');
        }

        $name = '';
        while ($index > 0) {
            $index--;
            $name = chr(65 + ($index % 26)) . $name;
            $index = intdiv($index, 26);
        }

        return $name;
    }

    private static function numericValue($value): string
    {
        if (is_int($value)) {
            return (string)$value;
        }

        if (!is_finite($value)) {
            return '0';
        }

        // Bắt buộc dấu chấm thập phân, không phụ thuộc locale máy chủ.
        $text = rtrim(rtrim(sprintf('%.15F', $value), '0'), '.');
        return $text === '' || $text === '-0' ? '0' : $text;
    }


    private static function textLength($value): int
    {
        if ($value === null) {
            return 0;
        }

        $text = (string)$value;
        $lines = preg_split('/\R/u', $text) ?: [$text];
        $max = 0;

        foreach ($lines as $line) {
            $length = function_exists('mb_strlen')
                ? mb_strlen($line, 'UTF-8')
                : strlen($line);
            $max = max($max, $length);
        }

        return $max;
    }

    private static function calculateColumnWidths(
        array $headers,
        array $rows,
        array $configuredWidths,
        array $metadata
    ): array {
        $columnCount = count($headers);
        $result = [];

        for ($index = 0; $index < $columnCount; $index++) {
            $configured = (float)($configuredWidths[$index] ?? 12);
            $contentWidth = self::textLength($headers[$index] ?? '') + 3;
            $result[$index] = max(8, $configured, $contentWidth);
        }

        foreach ($rows as $row) {
            if (!is_array($row)) {
                continue;
            }

            for ($index = 0; $index < $columnCount; $index++) {
                $contentWidth = self::textLength($row[$index] ?? '') + 3;
                $result[$index] = max($result[$index], $contentWidth);
            }
        }

        // Cột A vừa chứa STT vừa chứa nhãn phần thông tin file.
        // Đảm bảo các nhãn như "Loại dữ liệu", "Phạm vi xuất" không bị cắt.
        if ($columnCount > 0) {
            $metadataLabelWidth = 0;
            foreach (array_keys($metadata) as $label) {
                $metadataLabelWidth = max(
                    $metadataLabelWidth,
                    self::textLength((string)$label) + 3
                );
            }

            $result[0] = max($result[0], 16, $metadataLabelWidth);
        }

        // Giới hạn chiều rộng; nội dung dài hơn sẽ tự xuống dòng.
        foreach ($result as $index => $width) {
            $result[$index] = max(8, min(45, (float)$width));
        }

        return $result;
    }

    private static function cell(string $ref, $value, int $style = 4): string
    {
        if (is_int($value) || is_float($value)) {
            return '<c r="' . $ref . '" s="' . $style . '" t="n"><v>' .
                self::numericValue($value) .
                '</v></c>';
        }

        if (is_bool($value)) {
            return '<c r="' . $ref . '" s="' . $style . '" t="b"><v>' .
                ($value ? '1' : '0') .
                '</v></c>';
        }

        if ($value === null || (string)$value === '') {
            // Ô trống vẫn giữ style nhưng không tạo inlineStr rỗng.
            return '<c r="' . $ref . '" s="' . $style . '"/>';
        }

        $text = self::xml((string)$value);

        return '<c r="' . $ref . '" s="' . $style . '" t="inlineStr">' .
            '<is><t xml:space="preserve">' . $text . '</t></is>' .
            '</c>';
    }

    private static function safeSheetName(string $sheetName): string
    {
        $name = trim($sheetName);

        // Không dùng biểu thức chính quy có nhiều ký tự escape ở đây vì
        // một số phiên bản PCRE/PHP trên XAMPP có thể báo Unknown modifier.
        $name = str_replace(
            ['\\', '/', '?', '*', '[', ']', ':'],
            ' ',
            $name
        );
        $name = preg_replace('~[\x00-\x1F\x7F]+~', ' ', $name) ?? '';
        $name = preg_replace('~\s+~u', ' ', trim($name)) ?? '';
        $name = trim($name, " '\t\n\r\0\x0B");

        if ($name === '') {
            $name = 'Dữ liệu';
        }

        if (function_exists('mb_substr')) {
            return mb_substr($name, 0, 31, 'UTF-8');
        }

        return substr($name, 0, 31);
    }

    public static function write(
        string $path,
        string $title,
        array $metadata,
        array $headers,
        array $rows,
        array $widths,
        string $sheetName = 'Dữ liệu'
    ): void {
        if (!class_exists('ZipArchive')) {
            throw new RuntimeException(
                'PHP chưa bật extension ZipArchive. Hãy bật extension=zip trong php.ini rồi restart Apache.'
            );
        }

        if ($headers === []) {
            throw new InvalidArgumentException('Danh sách cột xuất không được để trống');
        }

        $columnCount = count($headers);
        $lastColumn = self::columnName($columnCount);
        $metadataCount = count($metadata);

        // Dòng 1: tiêu đề; dòng 2...: metadata; chừa một dòng trống; sau đó là header.
        $headerRow = 3 + $metadataCount;
        $dataStartRow = $headerRow + 1;
        $lastDataRow = $dataStartRow + count($rows) - 1;
        $totalRow = $lastDataRow + 1;

        $calculatedWidths = self::calculateColumnWidths(
            $headers,
            $rows,
            $widths,
            $metadata
        );

        $colsXml = '';
        for ($index = 0; $index < $columnCount; $index++) {
            $col = $index + 1;
            $safeWidth = $calculatedWidths[$index] ?? 18;

            $colsXml .= '<col min="' . $col . '" max="' . $col .
                '" width="' . $safeWidth .
                '" customWidth="1" bestFit="1"/>';
        }

        $sheetRows = [];
        $sheetRows[] = '<row r="1" ht="28" customHeight="1">' .
            self::cell('A1', $title, 1) .
            '</row>';

        $rowNumber = 2;
        foreach ($metadata as $label => $value) {
            $sheetRows[] = '<row r="' . $rowNumber . '">' .
                self::cell('A' . $rowNumber, (string)$label, 2) .
                self::cell('B' . $rowNumber, (string)$value, 3) .
                '</row>';
            $rowNumber++;
        }

        $headerCells = '';
        foreach ($headers as $index => $header) {
            $headerCells .= self::cell(
                self::columnName($index + 1) . $headerRow,
                (string)$header,
                5
            );
        }
        // Không cố định chiều cao header để Excel tự tăng khi chữ xuống dòng.
        $sheetRows[] = '<row r="' . $headerRow . '">' .
            $headerCells .
            '</row>';

        foreach ($rows as $rowIndex => $row) {
            if (!is_array($row)) {
                throw new InvalidArgumentException('Mỗi dòng xuất Excel phải là một mảng');
            }

            $excelRow = $dataStartRow + $rowIndex;
            $cells = '';

            for ($columnIndex = 0; $columnIndex < $columnCount; $columnIndex++) {
                $value = $row[$columnIndex] ?? null;
                $style = ($columnIndex === 0 || is_int($value) || is_float($value)) ? 6 : 4;

                $cells .= self::cell(
                    self::columnName($columnIndex + 1) . $excelRow,
                    $value,
                    $style
                );
            }

            $sheetRows[] = '<row r="' . $excelRow . '">' . $cells . '</row>';
        }

        $sheetRows[] = '<row r="' . $totalRow . '">' .
            self::cell('A' . $totalRow, 'Tổng số bản ghi', 7) .
            self::cell('B' . $totalRow, count($rows), 7) .
            '</row>';

        $mergeCells = ['A1:' . $lastColumn . '1'];

        // Chỉ merge các dòng metadata thật; không merge dòng trống trước header.
        $lastMetadataRow = 1 + $metadataCount;
        for ($r = 2; $r <= $lastMetadataRow; $r++) {
            if ($columnCount >= 2) {
                $mergeCells[] = 'B' . $r . ':' . $lastColumn . $r;
            }
        }

        $mergeXml = '<mergeCells count="' . count($mergeCells) . '">';
        foreach ($mergeCells as $range) {
            $mergeXml .= '<mergeCell ref="' . $range . '"/>';
        }
        $mergeXml .= '</mergeCells>';

        $autoFilterLastRow = max($headerRow, $lastDataRow);

        // Thứ tự phần tử tuân thủ CT_Worksheet:
        // sheetData -> autoFilter -> mergeCells -> pageMargins.
        $sheetXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>' .
            '<worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">' .
            '<dimension ref="A1:' . $lastColumn . $totalRow . '"/>' .
            '<sheetViews><sheetView workbookViewId="0">' .
            '<pane ySplit="' . $headerRow . '" topLeftCell="A' . ($headerRow + 1) .
            '" activePane="bottomLeft" state="frozen"/>' .
            '<selection pane="bottomLeft" activeCell="A' . ($headerRow + 1) .
            '" sqref="A' . ($headerRow + 1) . '"/>' .
            '</sheetView></sheetViews>' .
            '<sheetFormatPr defaultRowHeight="18"/>' .
            '<cols>' . $colsXml . '</cols>' .
            '<sheetData>' . implode('', $sheetRows) . '</sheetData>' .
            '<autoFilter ref="A' . $headerRow . ':' . $lastColumn . $autoFilterLastRow . '"/>' .
            $mergeXml .
            '<pageMargins left="0.25" right="0.25" top="0.5" bottom="0.5" header="0.2" footer="0.2"/>' .
            '</worksheet>';

        $stylesXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<styleSheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
  <fonts count="4">
    <font><sz val="11"/><name val="Calibri"/></font>
    <font><b/><color rgb="FFFFFFFF"/><sz val="18"/><name val="Calibri"/></font>
    <font><b/><color rgb="FF1F2937"/><sz val="11"/><name val="Calibri"/></font>
    <font><b/><color rgb="FFFFFFFF"/><sz val="11"/><name val="Calibri"/></font>
  </fonts>
  <fills count="5">
    <fill><patternFill patternType="none"/></fill>
    <fill><patternFill patternType="gray125"/></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF2F5597"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FFD9EAF7"/><bgColor indexed="64"/></patternFill></fill>
    <fill><patternFill patternType="solid"><fgColor rgb="FF4472C4"/><bgColor indexed="64"/></patternFill></fill>
  </fills>
  <borders count="2">
    <border><left/><right/><top/><bottom/><diagonal/></border>
    <border><left style="thin"><color rgb="FFB7C9E2"/></left><right style="thin"><color rgb="FFB7C9E2"/></right><top style="thin"><color rgb="FFB7C9E2"/></top><bottom style="thin"><color rgb="FFB7C9E2"/></bottom><diagonal/></border>
  </borders>
  <cellStyleXfs count="1"><xf numFmtId="0" fontId="0" fillId="0" borderId="0"/></cellStyleXfs>
  <cellXfs count="8">
    <xf numFmtId="0" fontId="0" fillId="0" borderId="0" xfId="0"/>
    <xf numFmtId="0" fontId="1" fillId="2" borderId="0" xfId="0" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>
    <xf numFmtId="0" fontId="2" fillId="3" borderId="1" xfId="0" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="3" fillId="4" borderId="1" xfId="0" applyAlignment="1"><alignment horizontal="center" vertical="center" wrapText="1"/></xf>
    <xf numFmtId="0" fontId="0" fillId="0" borderId="1" xfId="0" applyAlignment="1"><alignment horizontal="center" vertical="center"/></xf>
    <xf numFmtId="0" fontId="2" fillId="3" borderId="1" xfId="0" applyAlignment="1"><alignment vertical="center" wrapText="1"/></xf>
  </cellXfs>
  <cellStyles count="1"><cellStyle name="Normal" xfId="0" builtinId="0"/></cellStyles>
</styleSheet>';

        $contentTypes = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
  <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
  <Override PartName="/xl/styles.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.styles+xml"/>
  <Override PartName="/docProps/core.xml" ContentType="application/vnd.openxmlformats-package.core-properties+xml"/>
  <Override PartName="/docProps/app.xml" ContentType="application/vnd.openxmlformats-officedocument.extended-properties+xml"/>
</Types>';

        $rootRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/package/2006/relationships/metadata/core-properties" Target="docProps/core.xml"/>
  <Relationship Id="rId3" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/extended-properties" Target="docProps/app.xml"/>
</Relationships>';

        $safeSheetName = self::xml(self::safeSheetName($sheetName));
        $workbookXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
  <bookViews><workbookView activeTab="0"/></bookViews>
  <sheets><sheet name="' . $safeSheetName . '" sheetId="1" r:id="rId1"/></sheets>
</workbook>';

        $workbookRels = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
  <Relationship Id="rId2" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/styles" Target="styles.xml"/>
</Relationships>';

        $now = gmdate('Y-m-d\TH:i:s\Z');
        $coreXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<cp:coreProperties xmlns:cp="http://schemas.openxmlformats.org/package/2006/metadata/core-properties" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
  <dc:creator>CKC Class</dc:creator>
  <cp:lastModifiedBy>CKC Class</cp:lastModifiedBy>
  <dcterms:created xsi:type="dcterms:W3CDTF">' . $now . '</dcterms:created>
  <dcterms:modified xsi:type="dcterms:W3CDTF">' . $now . '</dcterms:modified>
</cp:coreProperties>';

        $appXml = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Properties xmlns="http://schemas.openxmlformats.org/officeDocument/2006/extended-properties" xmlns:vt="http://schemas.openxmlformats.org/officeDocument/2006/docPropsVTypes">
  <Application>CKC Class</Application>
  <DocSecurity>0</DocSecurity>
  <ScaleCrop>false</ScaleCrop>
</Properties>';

        $directory = dirname($path);
        if (!is_dir($directory) && !mkdir($directory, 0775, true) && !is_dir($directory)) {
            throw new RuntimeException('Không thể tạo thư mục lưu file Excel');
        }

        $zip = new ZipArchive();
        if ($zip->open($path, ZipArchive::CREATE | ZipArchive::OVERWRITE) !== true) {
            throw new RuntimeException('Không thể tạo file Excel trên server');
        }

        try {
            $files = [
                '[Content_Types].xml' => $contentTypes,
                '_rels/.rels' => $rootRels,
                'docProps/core.xml' => $coreXml,
                'docProps/app.xml' => $appXml,
                'xl/workbook.xml' => $workbookXml,
                'xl/_rels/workbook.xml.rels' => $workbookRels,
                'xl/styles.xml' => $stylesXml,
                'xl/worksheets/sheet1.xml' => $sheetXml,
            ];

            foreach ($files as $entryName => $content) {
                if (!$zip->addFromString($entryName, $content)) {
                    throw new RuntimeException('Không thể ghi thành phần ' . $entryName . ' vào file Excel');
                }
            }
        } catch (Throwable $e) {
            $zip->close();
            @unlink($path);
            throw $e;
        }

        if (!$zip->close()) {
            @unlink($path);
            throw new RuntimeException('Không thể hoàn tất file Excel');
        }
    }
}
