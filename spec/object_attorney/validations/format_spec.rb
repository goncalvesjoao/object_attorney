require 'spec_helper'

describe ObjectAttorney do
  describe '.validates_format_of' do
    context 'using the :with option' do
      before do
        @format_validator = Class.new(ObjectAttorney::Base) do
          validates_format_of \
            :title,
            with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i
        end
      end

      context 'given a resource with a valid title' do
        before do
          @post = Post.new(title: 'email@gmail.com')
          @format_validator.new(@post).valid?
        end

        it '@post should have no errors' do
          expect(@post.errors.empty?).to be true
        end
      end

      context 'given a resource with an invalid title' do
        before do
          @post = Post.new(title: 'emailmail.com')
          @format_validator.new(@post).valid?
        end

        it '@post should have an error' do
          expect(@post.errors.include?(:title)).to be true
        end
      end
    end

    context 'using the :without option' do
      before do
        @format_validator = Class.new(ObjectAttorney::Base) do
          validates_format_of :title, without: /@/i
        end
      end

      context 'given a resource with a valid title' do
        before do
          @post = Post.new(title: 'emailmailcom')
          @format_validator.new(@post).valid?
        end

        it '@post should have no errors' do
          expect(@post.errors.empty?).to be true
        end
      end

      context 'given a resource with an invalid title' do
        before do
          @post = Post.new(title: 'email@gmailcom')
          @format_validator.new(@post).valid?
        end

        it '@post should have an error' do
          expect(@post.errors.include?(:title)).to be true
        end
      end
    end
  end
end
