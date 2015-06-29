require 'saml2/namespaces'

module SAML2
  class Base
    def self.from_xml(node)
      return nil unless node
      new.from_xml(node)
    end

    def from_xml(node)
      self
    end

    def to_s
      # make sure to not FORMAT it - it breaks signatures!
      to_xml.to_xml(save_with: Nokogiri::XML::Node::SaveOptions::AS_XML)
    end

    def to_xml
      unless @document
        builder = Nokogiri::XML::Builder.new
        build(builder)
        @document = builder.doc
      end
      @document
    end

    def self.load_string_array(node, element)
      node.xpath(element, Namespaces::ALL).map do |node|
        node.content && node.content.strip
      end
    end

    def self.load_object_array(node, element, klass)
      node.xpath(element, Namespaces::ALL).map do |node|
        if klass.is_a?(Hash)
          klass[node.name].from_xml(node)
        else
          klass.from_xml(node)
        end
      end
    end

    def self.lookup_qname(qname, namespaces)
      prefix, local_name = split_qname(qname)
      [lookup_namespace(prefix, namespaces), local_name]
    end

    protected
    def load_string_array(node, element)
      self.class.load_string_array(node, element)
    end

    def load_object_array(node, element, klass)
      self.class.load_object_array(node, element, klass)
    end

    def self.split_qname(qname)
      if qname.include?(':')
        qname.split(':', 2)
      else
        [nil, qname]
      end
    end

    def self.lookup_namespace(prefix, namespaces)
      return nil if namespaces.empty?
      namespaces[prefix.empty? ? 'xmlns' : "xmlns:#{prefix}"]
    end
  end
end
