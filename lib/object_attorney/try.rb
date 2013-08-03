module ObjectAttorney
  module Try
    
    def try_or_return(*a, &b)
      if a.empty? || a.length < 2
        return self.try(a, b)
      else
        send_this = a.pop
        result = self.try(*a, &b)
        return result.nil? ? send_this : result
      end
    end

  end
end
