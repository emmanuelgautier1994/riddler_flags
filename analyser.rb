require "mini_magick"

class Analyser

    def initialize
    end

    def process_file file_path
        image = MiniMagick::Image.open file_path
        pixels = image.get_pixels.flatten(1)
        total_size = pixels.size.to_f
        color_count = Hash[
            pixels
            .group_by { |color| color.map {|x| x/10 } }
            .map { |k, v| [k, (v.size/total_size).round(3)]}
            .sort_by { |k, v| -v }
            .reject { |k, v| v < 0.01}
        ]

        return color_count
    end
    
    def process_folder folder_path
        puts 'processing ' + folder_path

        res = Hash.new
        count = 0
        Dir.foreach(folder_path) do |file|
                next if file == '.' or file == '..'
                res[file[/^[^\.]*(?=\.)/]] = process_file(folder_path + '/' + file)
                count += 1
                puts count.to_s + ' done'
            end
        res
    end

    def mysteries
        process_folder './mystery'
    end

    def references
        process_folder './ref'
    end

    def match_score a, b
        return -1 if a.size != b.size
        mse = (0...a.size).inject(0) { |acc, i| acc + (a[i] - b[i]) ** 2}
        return (1.0 / (1 + Math.sqrt(mse))).round(3)
    end

    def perform
        ms = mysteries
        rs = references

        puts 'Now comparing hashes'

        ms.each do |k_m, v_m|
            puts 'matches for ' + k_m
            scores = rs.map { |k_r, v_r| [k_r, match_score(v_m.values, v_r.values)] }.to_h.sort_by{|k, v| -v}.reject{|k, v| v < 0}
            puts scores.to_s
        end

        return true
    end
end