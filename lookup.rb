def get_command_line_argument
  # ARGV is an array that Ruby defines for us,
  # which contains all the arguments we passed to it
  # when invoking the script from the command line.
  # https://docs.ruby-lang.org/en/2.4.0/ARGF.html
  if ARGV.empty?
    puts "Usage: ruby lookup.rb <domain>"
    exit
  end
  ARGV.first
end

# `domain` contains the domain name we have to look up.
domain = get_command_line_argument

# File.readlines reads a file and returns an
# array of string, where each element is a line
# https://www.rubydoc.info/stdlib/core/IO:readlines
dns_raw = File.readlines("zone")

def parse_dns(raw)
	domains={}
	raw.
		reject {|record| record.empty? }.
		reject {|record| record[0] == "#" }.
		each do |record|
			rec_split=record.strip.split(", ")
			domains[rec_split[1]] = { rec_split[0] => rec_split[2] }
		end
		domains
end

def resolve(dns_records, lookup_chain, domain)
	record = dns_records[domain]
	if (!record)
		lookup_chain += ["Error: Domain Not In Record"]
	else
		record.each do |key, next_domain|
			if key == "A"
				lookup_chain += [next_domain]
			elsif key == "CNAME"
				lookup_chain += [next_domain]
				lookup_chain = resolve(dns_records, lookup_chain, next_domain)
			else
				lookup_chain += ["Invalid Record Type for "+domain]
			end
		end
	end
	lookup_chain
end

# To complete the assignment, implement `parse_dns` and `resolve`.
# Remember to implement them above this line since in Ruby
# you can invoke a function only after it is defined.
dns_records = parse_dns(dns_raw)
lookup_chain = [domain]
lookup_chain = resolve(dns_records, lookup_chain, domain)
puts lookup_chain.join(" => ")
