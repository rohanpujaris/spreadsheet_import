class Hash
  unless instance_methods.find { |m| m == :slice }
    def slice(*keys)
      keys.each_with_object({}) do |k, hash|
        hash[k] = self[k] if has_key?(k)
      end
    end
  end
end
