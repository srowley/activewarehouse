module ActiveWarehouse #:nodoc:
  module Report #:nodoc:
    # A report which is used to represent a tabular report.
    class TableReport
      include AbstractReport

      attr_accessor :format
      attr_accessor :link_cell
      attr_accessor :html_params

      # Get any format options
      def format
        @format ||= {}
      end

      # Set to true if cells should be linked
      def link_cell
        @link_cell ||= false
      end

      # Hash of HTML parameters
      def html_params
        @html_params ||= {}
      end

      def view(params, options = {})
        if options.has_key?(:sortable_with_totals)
          options[:sortable] = true
          options[:with_totals] = true
          options.delete(:sortable_with_totals)
        end

        ActiveWarehouse::View::TableView.new(self, params, options)
      end
      
      # TODO: figure out how tests passed with abstract report calling super
      # and this method not implemented.
      def initialize(attributes = {})
        attributes.each do |name, value|
          send("#{name}=", value)
        end
      end
      
    end
  end
end
