# = Collection
#
# Module which allows to use a proxy class for wrapping collections of all sorts.
#
# Let's take a collection of articles, for example (see also the test suite below).
#
# The collection item class could look like this:
#
#     class Article
#       attr_reader :title
#       def initialize(title); @title = title; end
#     end
#
# The collection class could look like this, using the provided DSL:
#
#    class ArticleCollection
#    include Collection
#
#      item_class Article                                     # 1)
#      item_key   :title                                      # 2)
#      load_collection do |*args|                             # 3)
#        args.pop.map { |title| item_class.new(title) }
#      end
#    end
#
# As you can see, you include the module and specify, which class should be collection items wrapped in [1],
# what is the main attribute for a collection item [2], and how you would like to load the collection [3].
#
# Note, that you can also override the corresponding methods directly (see tests below).
#
# This allows to do following operations with the collection:
#
#    articles = ArticleCollection.new  ['one', 'two']
#
#    puts "\n~~~ The collection..."
#    p articles
#
#    puts "\n~~~ Last item..."
#    p articles.last
#
#    puts "\n~~~ Add 'three' and 'four'..."
#    articles << 'three'
#    articles.add 'four'
#
#    p articles
#
#    puts "\n~~~ Deleting 'three' and 'four'..."
#    articles >> 'three'
#    articles.delete Article.new('four')
#
#    p articles
#
#    puts "\n~~~ Iteration..."
#    articles.each_with_index do |a, i|
#     puts "#{i+1}. #{a.title}"
#    end
#
#    puts "\n~~~ Mapping..."
#    p articles.map { |a| a.title }
#
#    puts "\n~~~ Accessors..."
#    p articles['one']
#    p articles.find 'two'
#
#    puts "\n~~~ Size..."
#    p articles.size
#
# You may want to customize adding/removing items to the collection, for example.
#
# That's easy: just re-implement the `<<` or `>>` methods with custom logic, and call `super()`:
#
#    def << item
#      return false unless Tag.new(:article => @article, :value => item).valid?
#
#      @article.tags = super(:article => @article, :value => item)
#      self
#    end
#    alias :add :<<
#
# -----------------------------------
# (c) 2001 Karel Minarik; MIT License
#
module Collection
  include Enumerable

  def self.included(base)
    base.extend DSL
    base.class_eval do
      def self.method_added(name)
        case name
          when :<< then alias_method :add,    name
          when :>> then alias_method :delete, name
          when :[] then alias_method :find,   name
        end
      end
    end
  end

  module DSL

    def item_class klass=nil
      klass ? @item_class = klass : @item_class
    end

    def item_key key=nil
      key ? @item_key = key : @item_key
    end

    def load_collection &block
      block_given? ? @load_collection = block : @load_collection
    end

  end

  def initialize(*args)
    if self.class.instance_variable_defined?(:@load_collection)
      @collection = load_collection.call(*args)
    else
      @collection = load_collection(*args)
    end
  end

  def << item
    item = item_class.new(item) unless item.is_a? item_class
    @collection << item
    self
  end
  alias :add :<<

  def >> item
    item = item.send(item_key) if item.respond_to? item_key
    @collection.reject! { |a| a.send(item_key) == item }
    self
  end
  alias :delete :>>

  def [] key
    @collection.select  { |a| a.send(item_key) == key }.first
  end
  alias :find :[]

  def last
    @collection.reverse.first
  end

  def <=> other
    self <=> other
  end

  def each(&block)
    @collection.each(&block)
  end

  def include? value
    @collection.any? { |i| i.send(item_key) == value }
  end

  def empty?
    @collection.empty?
  end

  def to_a
    @collection.map { |i| i.send(item_key) }
  end

  def size
    @collection.size
  end

  def inspect
    %Q|<#{self.class.name} #{@collection.inspect}>|
  end

  def load_collection
    self.class.load_collection ||
    raise(NoMethodError, "Please implement 'load_collection' method in your collection class")
  end

  def item_class
    self.class.item_class ||
    raise(NoMethodError, "Please implement 'item_class' method in your collection class")
  end

  def item_key
    self.class.item_key ||
    raise(NoMethodError, "Please implement 'item_key' method in your collection class")
  end

end


if $0 == __FILE__
  require 'rubygems'
  require 'test/unit'
  require 'shoulda'
  require 'mocha'

  class CollectionTest < Test::Unit::TestCase

    context "Collection module" do

      setup { class MyCollection; include Collection; end }

      should "have abstract methods" do
        assert_raise(NoMethodError) do
          MyCollection.new.load_collection
          MyCollection.new.item_class
          MyCollection.new.item_key
        end
      end

      should "pass arguments from initialize to load_collection" do
        list = ['one', 'two']
        MyCollection.any_instance.expects(:load_collection).with( list ).returns( list )

        MyCollection.new list
      end

      should "be iterable" do
        MyCollection.any_instance.stubs(:load_collection).returns( [] )

        assert_respond_to MyCollection.new, :each
        assert_respond_to MyCollection.new, :size
        assert_respond_to MyCollection.new, :empty?
      end

    end

    context "Collection module included" do

      setup do
        class Article
          attr_reader :title
          def initialize(title); @title = title; end
        end

        class ArticleCollection
          include Collection

          item_class Article
          item_key   :title
          load_collection do |*args|
            args.pop.map { |title| item_class.new(title) }
          end
        end

        @articles = ArticleCollection.new ['One', 'Two']
      end

      should "set item_class" do
        assert_equal Article, @articles.item_class
      end

      should "set item_key" do
         assert_equal :title, @articles.item_key
      end

      should "load the collection" do
        assert_equal 2, @articles.size
        assert_same_elements ['One', 'Two'], @articles.to_a
      end

      should "walk like an Enumerable" do
        assert_same_elements ['One', 'Two'], @articles.map { |a| a.title }
      end

      should "answer to empty?" do
        assert ! @articles.empty?
      end

      should "return size" do
        assert_equal 2, @articles.size
      end

      should "return first" do
        assert_equal 'One', @articles.first.title
      end

      should "return last" do
        assert_equal 'Two', @articles.last.title
      end

      should "add item by key" do
        assert @articles << 'Three'
        assert_equal 3, @articles.size
      end

      should "add item instance" do
        assert @articles << Article.new('Three')
        assert_equal 3, @articles.size
        assert_equal 'Three', @articles.last.title
      end

      should "remove item by key" do
        assert @articles >> 'Two'
        assert_equal 1, @articles.size
      end

      should "remove item instance" do
        assert @articles >> Article.new('Two')
        assert_equal 1, @articles.size
        assert_equal 'One', @articles.last.title
      end

      should "get item by key" do
        assert_not_nil @articles['One']
        assert_equal 'One', @articles['One'].title
      end

      should "query for item by key" do
        assert   @articles.include?('One'),       "#{@articles.inspect} should contain 'One'"
        assert ! @articles.include?('FourtyTwo'), "#{@articles.inspect} should NOT contain 'FourtyTwo'"
      end

      should "serialize collection to an Array, by key" do
        assert_same_elements ['One', 'Two'], @articles.to_a
      end

      should "have aliases" do
        assert_respond_to @articles, :add
        assert_respond_to @articles, :delete
        assert_respond_to @articles, :find
      end

    end

    context "Collection module used without DSL" do

      setup do
        class Article
           attr_reader :title
           def initialize(title); @title = title; end
         end

         class NoDSLArticleCollection
           include Collection

           def load_collection(*args); args.pop.map { |title| item_class.new(title) };  end
           def item_class;             Article;                                         end
           def item_key;               :title;                                          end
         end

         @articles = NoDSLArticleCollection.new ['One', 'Two']
      end

      should "set item_class" do
        assert_equal Article, @articles.item_class
      end

      should "set item_key" do
         assert_equal :title, @articles.item_key
      end

      should "load the collection" do
        assert_equal 2, @articles.size
        assert_same_elements ['One', 'Two'], @articles.to_a
      end

   end

   context "Collection with customized manipulation methods" do

     setup do
       class Article
         attr_reader :title
         def initialize(title); @title = title; end
       end

       class ArticleCollection
         include Collection

         item_class Article
         item_key   :title
         load_collection do |*args|
           args.pop.map { |title| item_class.new(title) }
         end

         def << item
           return false if item == 'foo'
           super
         end

         def >> item
           raise "Foorbidden!" if item == 'foo'
           super
         end

         def [] item
          return nil if item == 'One'
          super
         end

       end

       @articles = ArticleCollection.new ['One', 'Two']
     end

     should "return false when adding adding 'foo'" do
       assert ! (@articles << 'foo')
       assert_equal 2, @articles.size
     end

     should "raise exception when trying to remove 'foo'" do
       assert_raise(RuntimeError) do
         @articles >> 'foo'
         assert_equal 2, @articles.size
       end
     end

     should "have alias for add" do
       assert ! @articles.add('foo')
       assert_equal 2, @articles.size
     end

     should "have alias for delete" do
       assert_raise(RuntimeError) do
         @articles.delete('foo')
         assert_equal 2, @articles.size
       end
     end

     should "have alias for find" do
       assert_nil @articles.find('One')
     end

   end

  end
end
